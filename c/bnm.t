@example  @c
/*--   bnm.c -- Big NuMbers (integers) for Muq.				*/
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
/*-    Copyright.						        */
/************************************************************************/

/************************************************************************/
/* Author:       Jeff Prothero						*/
/* Created:      98Mar07						*/
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
/*-    Quote							        */
/*									*/
/*     "Mathematicians know many interesting things,			*/
/*	but never what a physicist wants to know."			*/
/*				-- Albert Einstein			*/
/*									*/
/************************************************************************/



/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

#define MAX_BNM_BIN2DEC 128
BNM_HEADER_REC(Bnm_Header_Rec128,MAX_BNM_BIN2DEC);



/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static Vm_Uch*    bnm_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj     bnm_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     bnm_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     bnm_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch*    bnm_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj     bnm_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     bnm_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void       bnm_export(  FILE*, Vm_Obj, Vm_Int );

static void       bnm_startup( void			);
static void       bnm_linkup(  void			);
static void       bnm_shutdown(void			);

static void	  mult( Bnm_P, Bnm_P, Bnm_P );

static Vm_Obj     dec2bin( Vm_Uch* );
static void       print( Vm_Uch* title, Bnm_P a );
static Vm_Obj     bnm_hash( Vm_Obj );

static Vm_Obj     bnm_byteswap_64bit_obj( Vm_Obj );


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

Obj_A_Type_Summary bnm_Type_Summary = {    OBJ_FROM_BYT1('n'),
    bnm_sprintX,
    bnm_sprintX,
    bnm_sprintX,
    bnm_for_del,
    bnm_for_get,
    bnm_g_asciz,
    bnm_for_set,
    bnm_for_nxt,
    obj_X_Key,
    bnm_hash,
    bnm_byteswap_64bit_obj,
    obj_Type_Get_Mos_Key,	/* buggo? */
    bnm_import,
    bnm_export,
    "bignum",
    KEY_LAYOUT_BIGNUM,
    OBJ_0
};

static void bnm_doTypes(void){
    if (mod_Type_Summary[ OBJ_TYPE_BIGNUM ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_BIGNUM");
    }

    mod_Type_Summary[ OBJ_TYPE_BIGNUM ] = &bnm_Type_Summary;
}
Obj_A_Module_Summary bnm_Module_Summary = {
   "bnm",
    bnm_doTypes,
    bnm_startup,
    bnm_linkup,
    bnm_shutdown
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Standard Static fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    bnm_startup -- start-of-world stuff.				*/
/************************************************************************/

static void bnm_startup ( void ) {

    static int done_startup = FALSE;
    if        (done_startup)   return;
    done_startup	    = TRUE;
}



/************************************************************************/
/*-    bnm_linkup -- start-of-world stuff.				*/
/************************************************************************/

static void bnm_linkup ( void ) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    bnm_shutdown -- end-of-world stuff.				*/
/************************************************************************/

static void bnm_shutdown ( void ) {

    static int done_shutdown = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	     = TRUE;
}

/************************************************************************/
/*-    maybeConvertToFixnum -- Re-express bignum as fixnum if possible.	*/
/************************************************************************/

/* Define largest value which we can represent as a positive immediate  */
/* integer.  MAX_FIXNUM is actually one larger than this value:         */
#undef  MAX_FIXNUM
#define MAX_FIXNUM ((Vm_Unt)((Vm_Int)1 << (VM_INTBITS-(OBJ_INT_SHIFT+1))))

static Vm_Obj
maybeConvertToFixnum(
    Vm_Obj oa,		/* Object to maybe convert.	*/
    Bnm_P  a		/* Address of 'a' else NULL.	*/
) {
    if (!a)   a = BNM_P(oa);
    if (a->length != (Vm_Unt)1)   return oa;

    /* See if value will fit in an immediate value,    */
    /* remembering that we can represent one more      */
    /* negative than positive value in 2's complement: */
    {	Vm_Unt u = a->slot[0];
        if (a->sign  == (Vm_Unt)1) {   if (u <  MAX_FIXNUM)   return OBJ_FROM_INT(  u ); }
	else                       {   if (u <= MAX_FIXNUM)   return OBJ_FROM_INT( -u ); }
    }

    return oa;
}

/************************************************************************/
/*-    bnm_Alloc -- Return a new 'n'-slot bignum.			*/
/************************************************************************/

/* No particular rationale for this size, other than */
/* keeping values small enough to print as strings:  */
#ifndef MAX_BIGNUM
#define MAX_BIGNUM (8192/VM_INTBITS)
#endif

Vm_Obj
bnm_Alloc(
    Vm_Unt n,
    Vm_Unt a
) {
    if (n <  1)   n = 1;	/* Cheap insurance.		*/
    if (n >= MAX_BIGNUM)   MUQ_WARN("bnm_Alloc: bignum larger than currently supported");
    {   Vm_Obj pkg = JOB_P(jS.job)->package;
	Vm_Int siz = sizeof(Bnm_A_Header) + (n-1) * sizeof(Vm_Unt);
	Vm_Obj o = vm_Malloc( siz, VM_DBFILE(pkg), OBJ_K_BIGNUM );

	/* Initializing the vector is presumably wasted effort  */
	/* most of the time, but makes debugging more pleasant: */
	Bnm_P  p = BNM_P( o );
	Vm_Unt u;
	p->private = FALSE;
	p->is_a  = bnm_Type_Summary.builtin_class;
	p->physicalLength= n;
	p->length= n;
	p->sign  = 1;
	for   (u = n;   u --> 0;   ) {
	    p->slot[u] = a;
	}
	vm_Dirty(o);

	job_RunState.bytes_owned += siz;

	return o;
    }
}

/************************************************************************/
/*-    hex2bin2								*/
/************************************************************************/

static Vm_Int
hex2bin2(
    int c
) {
    c = tolower(c);
    if (c >= 'a')   return (Vm_Int)(c-('a'-10));
    return (Vm_Int)(c-'0');
}

/************************************************************************/
/*-    hex2bin								*/
/************************************************************************/

static Vm_Obj
hex2bin(
    Vm_Uch* buf
) {
    Vm_Int sign = (Vm_Int) 1;

    /* Check that string is all legal hex chars: */
    Vm_Uch* t;
    int len;
    if (!strncmp(buf,"0x",2)) 	buf += 2;
    if (!strncmp(buf,"#x",2)) 	buf += 2;
    if (*buf == '-') {
	sign = (Vm_Int) -1;
	++buf;
    }
    for (t = buf, len=(Vm_Int)0;   *t;   ++t, ++len) {
	Vm_Uch c = *t;
	if (!isxdigit(c)) MUQ_WARN("Illegal hex digit %c\n",c);
    }

    /* So how many Vm_Unts do we need to hold it? */
    {   int nybblesNeeded= len;
	int vmintsNeeded = nybblesNeeded /  (VM_INTBYTES*2);
	int oddNybbles   = nybblesNeeded & ((VM_INTBYTES*2)-1);
	if (oddNybbles) ++vmintsNeeded;

	/* Allocate it: */
	{   Vm_Obj o = bnm_Alloc( vmintsNeeded, (Vm_Unt)0 );

	    /* Fill it in: */
	    {   Bnm_P p = BNM_P(o);
		int i,j;
		p->sign = sign;
		if (oddNybbles) {
		    Vm_Int val = (Vm_Int)0;
		    for (i = 0;  i < oddNybbles;   ++i) {
			val <<= 4;
			val  |= hex2bin2( buf[i] );
		    }
		    p->slot[vmintsNeeded-1] = val;
		    buf += oddNybbles;
		    vmintsNeeded --;
		}
		for (j = vmintsNeeded;   j --> 0; ) {
		    Vm_Int val = (Vm_Int)0;
		    for (i = 0;  i < VM_INTBYTES*2;   ++i) {
			val <<= 4;
			val  |= hex2bin2( buf[i] );
		    }
		    p->slot[j] = val;
		    buf += VM_INTBYTES*2;
		}
	    }   vm_Dirty(o);

	    return o;
    }   }
}

/************************************************************************/
/*-    bnm_Alloc_Asciz -- Return a new bignum given hex representation.	*/
/************************************************************************/


Vm_Obj
bnm_Alloc_Asciz(
    Vm_Uch* buf
) {
    /* Support hex numbers in 0x1456 format, plus decimal: */
    if (!strncmp(buf, "#x" , 2))   return hex2bin( buf );
    if (!strncmp(buf, "0x" , 2))   return hex2bin( buf );
    if (!strncmp(buf, "#x-", 3))   return hex2bin( buf );
    if (!strncmp(buf, "0x-", 3))   return hex2bin( buf );
    return dec2bin( buf );
}



/************************************************************************/
/*-    set -- Copy contents between equal-sized bignums.		*/
/************************************************************************/

static void
set(
    Bnm_P c,
    Bnm_P a
) {
    int len = (int)a->length;
#ifdef NOISY
printf("set: a->length d=%d\n",len);
printf("set: a->physicalLength d=%" VM_D "\n",a->physicalLength);
printf("set: c->length d=%" VM_D "\n",c->length);
printf("set: c->physicalLength d=%" VM_D "\n",c->physicalLength);
print("a",a);
#endif

    #if MUQ_IS_PARANOID
    if (c->physicalLength < len) {
printf("set: c.physLen d=%" VM_D "\n",c->physicalLength);
printf("set: a.length  d=%" VM_D "\n",a->length);
	MUQ_FATAL("bnm:set: c.physLen < a.len err");
    }
    #endif

    {   int i     = len-1;
/*      for (;   i >= len;   --i) {  c->slot[i] = (Vm_Unt)0;  } */
        for (;   i >=   0;   --i) {  c->slot[i] = a->slot[i]; }
    }

    c->sign   = a->sign;
    c->length = a->length;
}

/************************************************************************/
/*-    bnm_Dup -- Return exact duplicate of 'o'.			*/
/************************************************************************/

Vm_Obj
bnm_Dup(
    Vm_Obj oa
) {
    /* Create appropriately sized bignum: */
    Vm_Int len = BNM_P(oa)->length;
    Vm_Obj oc  = bnm_Alloc( len, (Vm_Int)0 );

    /* Copy contents of oa into ob: */
    Bnm_P  a;
    Bnm_P  c;
    vm_Loc2( (void**)&a, (void**)&c, oa, oc );
    c->length = a->length;	/* Should be redundant.	*/
    set( c, a );

    return oc;
}

/************************************************************************/
/*-    zero -- Zero out a bignum.					*/
/************************************************************************/

static void
zero(
    Bnm_P a
) {
    int len   = (int)a->physicalLength;
    int i     = len;
    while (i --> 0)   a->slot[i] = (Vm_Unt)0;
    a->sign   = (Vm_Int)1;
    a->length = 1;
}

/************************************************************************/
/*-    unit -- one out a bignum.					*/
/************************************************************************/

static void
unit(
    Bnm_P a
) {
    int len    = (int)a->physicalLength;
    int i      = len;
    while (i --> 0)   a->slot[i] = (Vm_Unt)0;
    a->slot[0] = (Vm_Unt)1;
    a->sign    = (Vm_Int)1;
    a->length  = 1;
}

/************************************************************************/
/*-    bin2hex								*/
/************************************************************************/

#ifndef NEEDED_FOR_HEX_OUTPUT
static int
bin2hex(
    int c
) {
    if (c <= 9)   return '0'+c;
    return 'a' + (c-10);
}
#endif

/************************************************************************/
/*-    bnm_sprintX -- Debug dump of int state, multi-line format.	*/
/************************************************************************/

static Vm_Uch* bin2dec( Vm_Uch*, Vm_Uch*, Bnm_P );

static Vm_Uch*
bnm_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
#ifdef NEEDED_FOR_HEX_OUTPUT
    {   Bnm_P p        = BNM_P(obj);
	int vmints     = p->length;
	int nybbles    = vmints * VM_INTBYTES*2 + ((int)p->sign == -1);

	if (p->private) {
	    switch (p->private) {
	    case BNM_DIFFIE_HELLMAN_PRIVATE_KEY:
		return lib_Sprint( buf, lim, "#<TrueName>" );
	    case BNM_DIFFIE_HELLMAN_SHARED_SECRET:
		return lib_Sprint( buf, lim, "#<DiffieHellmanSharedSecret>" );
	    default:
		return lib_Sprint( buf, lim, "#<PrivateBignum>" );
	    }
	}

	/* Make sure number will fit in output buffer: */
	if (nybbles >= lim-buf) {
	    return  lib_Sprint( buf, lim, "#<bignum>" );
	}
	if ((int)p->sign == -1)   *buf++ = '-';
	{   int seenNonzero = FALSE;
	    int i,j;
	    for (j = vmints;   j --> 0; ) {
		for (i = VM_INTBITS;  i -= 4, i >= 0;   ) {
		    int val = (int)((p->slot[j] >> i) & (Vm_Int)0xF);
		    if (!val && !seenNonzero)   continue;
		    *buf++ = bin2hex(val);
		    seenNonzero = TRUE;
		}
	    }
	    if (!seenNonzero) *buf++ = '0';
	}
    }
    return  buf;
#else
    {   Bnm_P p        = BNM_P(obj);
	int vmints     = p->length;
	int nybbles    = vmints * VM_INTBYTES*3 + ((int)p->sign == -1);
#ifdef NOISY
printf("bnm_sprintX: obj x=%" VM_X "\n",obj);
printf("bnm_sprintX: p p=%p\n",p);
printf("bnm_sprintX: vmints d=%d\n",vmints);
printf("bnm_sprintX: nybbles d=%d\n",nybbles);
printf("bnm_sprintX: lim-buf d=%d\n",lim-buf);
#endif

	if (p->private) {
	    switch (p->private) {
	    case BNM_DIFFIE_HELLMAN_PRIVATE_KEY:
		return lib_Sprint( buf, lim, "#<TrueName>" );
	    case BNM_DIFFIE_HELLMAN_SHARED_SECRET:
		return lib_Sprint( buf, lim, "#<DiffieHellmanSharedSecret>" );
	    default:
		return lib_Sprint( buf, lim, "#<PrivateBignum>" );
	    }
	}

	/* Make sure number will fit in output buffer: */
	if (nybbles >= lim-buf) {
#ifdef NOISY
printf("bnm_sprintX: number too big for buf, abbreviating to #<bignum>\n");
#endif
	    return  lib_Sprint( buf, lim, "#<bignum>" );
	}
	{   Vm_Uch* result = bin2dec( buf, lim, BNM_P(obj) );
#ifdef NOISY
printf("bnm_sprintX: DONE\n");
#endif
	    return result;
	}
    }
#endif
}

/************************************************************************/
/*-    sprint -- temp Debug hak 					*/
/************************************************************************/

#ifndef SOMETIMES_USEFUL
static Vm_Uch*
sprint(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Bnm_P   p,
    Vm_Int  qot
) {
    int vmints     = p->length;
    int nybbles    = vmints * VM_INTBYTES*2 + ((int)p->sign == -1);

    /* Make sure number will fit in output buffer: */
    if (nybbles >= lim-buf) {
	return lib_Sprint( buf, lim, "#<bignum>" );
    }
    if ((int)p->sign == -1)   *buf++ = '-';
    {   int seenNonzero = FALSE;
	int i,j;
	for (j = vmints;   j --> 0; ) {
	    for (i = VM_INTBITS;  i -= 4, i >= 0;   ) {
		int val = (int)((p->slot[j] >> i) & (Vm_Int)0xF);
		if (!val && !seenNonzero)   continue;
		*buf++ = bin2hex(val);
		seenNonzero = TRUE;
	    }
	}
	if (!seenNonzero) *buf++ = '0';
    }
    return buf;
}
#endif

/************************************************************************/
/*-    bnm_Print -- temporary debug hack 				*/
/************************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

#ifdef SOMETIMES_USEFUL
void
bnm_Print( Vm_Uch* title ) {
    Vm_Uch buf[ MAX_STRING ];
    fprintf(stderr,"bnm_Print(%s)...\n",title);
    if (OBJ_IS_BIGNUM(obj_Sil_Test_Slot)) {
	Vm_Uch* end = bnm_sprintX(
	    buf,
	    buf+MAX_STRING,
	    obj_Sil_Test_Slot,
	    FALSE
	);
	*end = '\0';
	fprintf(stderr,"%s\n",buf);
    }
}
#endif

/************************************************************************/
/*-    print -- temporary debug hack 					*/
/************************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

#ifndef SOMETIMES_USEFUL
static void
print( Vm_Uch* title, Bnm_P a ) {
    Vm_Uch buf[ MAX_STRING ];
    fprintf(stderr,"print(%s): ",title);

    {   Vm_Uch* end = sprint(
	    buf,
	    buf+MAX_STRING,
	    a,
	    FALSE
	);
	*end = '\0';
    }
    fprintf(stderr,"%s\n",buf);
}
#endif

/************************************************************************/
/*-    normalize							*/
/************************************************************************/

static void
normalize(
    Bnm_P p
) {
    /* Drop any nonfinal zero leading words:      */
    int  i;
    for (i = p->length;   i > 1 && !p->slot[i-1];   --i);
    p->length = (Vm_Unt)i;

    /* Avoid negative zero: */
    if (i == 1   &&   !p->slot[0])   p->sign = (Vm_Int)1;
}

/************************************************************************/
/*-    magOrder -- qualitatively compare two bignums, IGNORING SIGN	*/
/************************************************************************/

#undef  LESS
#undef  EQUAL
#undef  MORE

#define LESS  (-1)
#define EQUAL (0)
#define MORE  (1)

static int	/* result <0 if a<b   ==0 if a==b   >0 if a>b		*/
magOrder(
    Bnm_P a,
    Bnm_P b
) {
    int   lena = a->length;
    int   lenb = b->length;

    if (lena != lenb)   return (lena < lenb) ? LESS : MORE;

    {   int  i;
	for (i = lena;   i --> 0;   ) {
	    Vm_Unt ai = a->slot[i];
	    Vm_Unt bi = b->slot[i];
	    if      (ai != bi) {
		if  (ai <  bi)   return LESS;
		else             return MORE;
	    }
	}
	return EQUAL;
    }    
}

/************************************************************************/
/*-    order -- qualitatively compare two bignums, including sign	*/
/************************************************************************/

#undef  POS_POS
#undef  POS_NEG
#undef  NEG_POS
#undef  NEG_NEG

#define POS_POS  3
#define POS_NEG  1
#define NEG_POS -1
#define NEG_NEG -3

static int	/* result <0 if a<b   ==0 if a==b   >0 if a>b		*/
order(
    Bnm_P a,
    Bnm_P b
) {
    int     sa     = (int) a->sign;
    int     sb     = (int) b->sign;
    int     signab = (sa << 1) +sb;
    switch (signab) {
    case POS_POS:   return magOrder(a,b);
    case NEG_NEG:   return magOrder(b,a);
    case POS_NEG:   return MORE;
    case NEG_POS:   return LESS;
    }
    return LESS; /* Strictly to quiet compilers. */
}

/************************************************************************/
/*-    bnm_Equal -- compare two bignums					*/
/************************************************************************/

Vm_Obj
bnm_Equal(
    Vm_Obj oa,
    Vm_Obj ob
){
    Bnm_P  a;
    Bnm_P  b;
    vm_Loc2( (void**)&a, (void**)&b, oa, ob );

    return (order(a,b)==EQUAL)   ?   OBJ_T  :  OBJ_NIL;
}
    
/************************************************************************/
/*-    bnm_Morethan -- compare two bignums				*/
/************************************************************************/

Vm_Obj
bnm_Morethan(
    Vm_Obj oa,
    Vm_Obj ob
){
    Bnm_P  a;
    Bnm_P  b;
    vm_Loc2( (void**)&a, (void**)&b, oa, ob );

    return (order(a,b) == MORE)   ?   OBJ_T     :   OBJ_NIL;
}
    
/************************************************************************/
/*-    bnm_NeqlBB -- compare bignum to bignum				*/
/************************************************************************/

Vm_Int
bnm_NeqlBB(
    Vm_Obj oa,
    Vm_Obj ob
){
    Bnm_P  a;
    Bnm_P  b;
    vm_Loc2( (void**)&a, (void**)&b, oa, ob );

    /* Avoid leaking secrets via comparison ops, */
    /* while attempting to avoid breaking code   */
    /* which merely needs an arbitrary ordering: */
    if (a->private | b->private) {
	if (oa < ob)  return LESS;
	if (oa > ob)  return MORE;
	return EQUAL;
    }

    return (Vm_Int)order( a, b );
}
    
/************************************************************************/
/*-    bnm_NeqlBI -- compare bignum to fixnum				*/
/************************************************************************/

Vm_Int
bnm_NeqlBI(
    Vm_Obj oa,
    Vm_Int ib
){
    Bnm_P  a = vm_Loc(oa);
    struct Bnm_Header_Rec128 xb;
    xb.physicalLength = (Vm_Unt)128;
    xb.length         = (Vm_Unt)1;
    xb.private        = FALSE;
    xb.is_a           = bnm_Type_Summary.builtin_class;

    if (ib < 0) {  xb.slot[0] = -ib;   xb.sign = (Vm_Int)-1; }
    else        {  xb.slot[0] =  ib;   xb.sign = (Vm_Int) 1; }

    return (Vm_Int)order( a, (Bnm_P)&xb );
}
    
/************************************************************************/
/*-    bnm_NeqlIB -- compare fixnum to bignum				*/
/************************************************************************/

Vm_Int
bnm_NeqlIB(
    Vm_Int ia,
    Vm_Obj ob
){
    Bnm_P  b = vm_Loc(ob);
    struct Bnm_Header_Rec128 xa;
    xa.physicalLength = (Vm_Unt)128;
    xa.length         = (Vm_Unt)1;
    xa.private        = FALSE;
    xa.is_a           = bnm_Type_Summary.builtin_class;

    if (ia < 0) {  xa.slot[0] = -ia;   xa.sign = (Vm_Int)-1; }
    else        {  xa.slot[0] =  ia;   xa.sign = (Vm_Int) 1; }

    return (Vm_Int)order( (Bnm_P)&xa, b );
}
    
/************************************************************************/
/*-    add_one_bit -- Add 1<<n into a bignum, in place.			*/
/************************************************************************/

static void
add_one_bit(
    Bnm_P a,
    int   n
) {
    /* Figure out where to start: */
    int len    = (int)a->length;
    int i      = n >> VM_LOG2_INTBITS;		    /* Word to add into.*/
    Vm_Unt v   = ((Vm_Unt)1) << (n & (VM_INTBITS-1));	/* Val to add.	*/

    /* Do the basic bit addition: */
    Vm_Unt t   = a->slot[i];
    Vm_Unt u   = t + v;
    #if MUQ_IS_PARANOID
    if (i >= (int)a->physicalLength) MUQ_FATAL("bnm:add_one_bit: internal err");
    #endif
    a->slot[i] = u;
#ifdef NOISY
printf("add_one_bit: n d=%d\n",n);
printf(" len d=%d\n",len);
printf(" i d=%d\n",i);
printf(" v x=%" VM_X "\n",v);
printf(" t x=%" VM_X "\n",t);
printf(" u x=%" VM_X "\n",u);
#endif

    /* Do carry propagation as needed: */
    while (u < t) {
	if (++i == len)   break;	/* Shouldn't be possible.	*/
	t          = a->slot[i];
	u          = t + (Vm_Unt)1;
	#if MUQ_IS_PARANOID
	if (i >= (int)a->physicalLength) MUQ_FATAL("bnm:add_one_bit: internal err");
	#endif
	a->slot[i] = u;
#ifdef NOISY
printf(" a->slot[%d] now x=%" VM_X "\n",i,u);
#endif
    }
#ifdef NOISY
printf(" a->length was x=%" VM_X "\n",a->length);
#endif
    if (i+1 > (int)a->length) {
	a->length = (Vm_Unt)(i+1);
#ifdef NOISY
printf(" a->length set to x=%" VM_X "\n",a->length);
#endif
    }

    normalize( a );
#ifdef NOISY
print("add_one_bit final value",a);
printf(" a->length normalized to x=%" VM_X "\n",a->length);
#endif
}

/************************************************************************/
/*-    adds -- static sum of two bignums, result sign given		*/
/************************************************************************/

static void
adds(
    Bnm_P  c,	/* Result	*/
    Bnm_P  a,	/* Input A	*/
    Bnm_P  b,	/* Input B	*/
    int    resultSign
) {
    Vm_Unt lena = a->length;
    Vm_Unt lenb = b->length;

    /* Make 'a' the longest of the two inputs: */
    if (lena < lenb)   return adds( c, b, a, resultSign );

    #if MUQ_IS_PARANOID
    if (c->physicalLength < a->length) {
printf("adds: c->physicalLength d=%" VM_D "\n",c->physicalLength);
printf("adds: a->length d=%" VM_D "\n",a->length);
printf("adds: b->length d=%" VM_D "\n",b->length);
print("a",a);
print("b",b);
	MUQ_FATAL("bnm:adds: internal err");
    }
    #endif

    {   /* Handle the stretch where we have */
	/* input from both 'a' and 'b':     */
	Vm_Unt x;
	Vm_Unt lo;
	Vm_Unt hi;
	Vm_Unt carry = (Vm_Unt)0;
	int len = b->length;
	int i   = 0;
	for (;   i < len;   ++i) {
	    x          = a->slot[i];	/* Fetch first input.		*/
	    lo         = x + b->slot[i];/* Add second input.		*/
	    hi         = lo < x;	/* Test for overflow.		*/
	    x          = lo + carry;	/* Add in carry from last add.	*/
	    c->slot[i] = x;		/* Save result.			*/
	    carry      = (x < lo) + hi;	/* Generate next carry.		*/
	}

	/* Handle the stretch where we */
	/* have input from only 'a':   */
	len = a->length;
	for (;   i < len;   ++i) {
	    x          = carry + a->slot[i];  /* Add carry-in to input. */
	    c->slot[i] = x;		      /* Save result word.	*/
	    carry      = x < carry;	      /* Generate carry-out.	*/
	}

	/* Handle final carry-out: */
	if (carry) {
	    #if MUQ_IS_PARANOID
	    if (i >= (int)c->physicalLength) MUQ_FATAL("bnm:subs: internal err");
	    #endif
	    c->slot[i]     = carry;
	}
	c->length      = (Vm_Unt)len + carry;
	c->sign        = (Vm_Unt)resultSign;

	normalize(c);
    }
}

/************************************************************************/
/*-    sub_in_place -- in-place difference of two bignums		*/
/************************************************************************/

static void
sub_in_place(
    Bnm_P a,	/* First operand, and also result.			*/
    Bnm_P b	/* Subtract this from 'a'.				*/
) {
    /* This function is a support hack for bnm_Divmod()			*/

    Vm_Unt lena = a->length;
    Vm_Unt lenb = b->length;

    /* Handle the stretch where we have */
    /* input from both 'a' and 'b':     */
    Vm_Unt x;
    Vm_Int lo;
    Vm_Int hi    = (Vm_Int)0;
    Vm_Int carry = (Vm_Int)0;
    int len = lenb;
    int i   = 0;
    for (;   i < len;   ++i) {
	x          = (Vm_Unt)(a->slot[i]);	/* Fetch first input	*/
	lo	   = (Vm_Int)(x - b->slot[i]);  /* Subtract second input*/
	hi	   = (Vm_Int) -((Vm_Unt)lo > x);/* Test for underflow	*/
	x	   = (Vm_Unt)(lo + carry);	/* Do carry-in		*/
	a->slot[i] = x;				/* Save result.		*/
	carry	   = (Vm_Int)(-(x > (Vm_Unt)lo)) + hi; /* Note carry-out*/
    }

    /* Handle the stretch where we */
    /* have input from only 'a':   */
    len = lena;
    for (;   i < len;   ++i) {
	lo	   = a->slot[i];		/* Fetch input	        */
	x          = carry + lo;		/* Add carry-in to input*/
	a->slot[i] = x;		      		/* Save result word.	*/
	carry      = (Vm_Int)(-(x > (Vm_Unt)lo));/* Generate carry-out.	*/
    }

    normalize( a );
}

/************************************************************************/
/*-    subs -- static difference of two bignums, result sign given	*/
/************************************************************************/

static void
subs(
    Bnm_P  c,	/* Result.						*/
    Bnm_P  a,	/* Input A. Caller guarantees a->length >= b->length.	*/
    Bnm_P  b,	/* Input B.						*/
    int    resultSign
) {
    Vm_Unt lena = a->length;
    Vm_Unt lenb = b->length;

    /* Handle the stretch where we have */
    /* input from both 'a' and 'b':     */
    Vm_Unt x;
    Vm_Int lo;
    Vm_Int hi    = (Vm_Int)0;
    Vm_Int carry = (Vm_Int)0;
    int len = lenb;
    int i   = 0;

    #if MUQ_IS_PARANOID
    if (c->physicalLength < a->length) MUQ_FATAL("bnm:subs: internal err");
    if (a->physicalLength < b->length) MUQ_FATAL("bnm:subs: internal err");
    #endif

    for (;   i < len;   ++i) {
	x          = (Vm_Unt)(a->slot[i]);	/* Fetch first input	*/
	lo	   = (Vm_Int)(x - b->slot[i]);  /* Subtract second input*/
	hi	   = (Vm_Int) -((Vm_Unt)lo > x);/* Test for underflow	*/
	x	   = (Vm_Unt)(lo + carry);	/* Do carry-in		*/
	c->slot[i] = x;				/* Save result.		*/
	carry	   = (Vm_Int)(-(x > (Vm_Unt)lo)) + hi; /* Note carry-out*/
    }

    /* Handle the stretch where we */
    /* have input from only 'a':   */
    len = lena;
    for (;   i < len;   ++i) {
	lo	   = a->slot[i];		/* Fetch input	        */
	x          = carry + lo;		/* Add carry-in to input*/
	c->slot[i] = x;		      		/* Save result word.	*/
	carry      = (Vm_Int)(-(x > (Vm_Unt)lo));/* Generate carry-out.	*/
    }

    c->length      = (Vm_Unt)len;

    if (carry) MUQ_FATAL("bnm:sub: nonzero final carry");

    c->sign	   = (Vm_Int) resultSign;
    normalize(c);
}

/************************************************************************/
/*-    add -- static add of two bignums					*/
/************************************************************************/

static void
add(
    Bnm_P c,
    Bnm_P a,
    Bnm_P b
){
    int     sa     = (int) a->sign;
    int     sb     = (int) b->sign;
    int     signab = (sa << 1) +sb;
    switch (signab) {
    case POS_POS:
    case NEG_NEG:                              return adds(c,a,b,sa);
    case POS_NEG: if (magOrder(a,b) == MORE)   return subs(c,a,b, 1);
		  else                         return subs(c,b,a,-1);
    case NEG_POS: if (magOrder(b,a) == MORE)   return subs(c,b,a, 1);
		  else                         return subs(c,a,b,-1);
    }
}

/************************************************************************/
/*-    bnm_Add -- add two bignums					*/
/************************************************************************/

Vm_Obj
bnm_Add(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Unt lena = BNM_P(oa)->length;
    Vm_Unt lenb = BNM_P(ob)->length;
    Vm_Unt lenc = (lena > lenb) ? lena+(Vm_Unt)1 : lenb+(Vm_Unt)1;
    Vm_Obj oc   = bnm_Alloc( lenc, (Vm_Unt)0 );

    Bnm_P  a;
    Bnm_P  b;
    Bnm_P  c;
    vm_Loc3( (void**)&a, (void**)&b, (void**)&c, oa, ob, oc );

    add( c, a, b );
    vm_Dirty(oc);
#ifndef SOON
/* At the moment this breaks half our regression test :( */
    oc = maybeConvertToFixnum( oc, c );
#endif

    return oc;
}
    
/************************************************************************/
/*-    bnm_AddBI -- add bignum to fixnum				*/
/************************************************************************/

Vm_Obj
bnm_AddBI(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Unt lena = BNM_P(oa)->length;
    Vm_Unt lenc = lena+(Vm_Unt)1;
    Vm_Int b    = OBJ_TO_INT(ob);
    Vm_Obj oc   = bnm_Alloc( lenc, (Vm_Unt)0 );
    struct Bnm_Header_Rec128 xb;
    xb.physicalLength = (Vm_Unt)128;
    xb.length         = (Vm_Unt)1;
    xb.private        = FALSE;
    xb.is_a           = bnm_Type_Summary.builtin_class;

    if (b < 0) {    xb.slot[0]    = -b; xb.sign = (Vm_Int)-1; }
    else {          xb.slot[0]    =  b; xb.sign = (Vm_Int) 1; }

    {   Bnm_P  a;
	Bnm_P  c;
	vm_Loc2( (void**)&a, (void**)&c, oa, oc );

	add( c, a, (Bnm_P)&xb );
        vm_Dirty(oc);
        oc = maybeConvertToFixnum( oc, c );
    }

    return oc;
}
    
/************************************************************************/
/*-    bnm_AddII -- add two fixnums					*/
/************************************************************************/

Vm_Obj
bnm_AddII(
    Vm_Int a,
    Vm_Int b
){
    /****************************************/
    /* This routine is normally called only */
    /* if the fixnum addition overflows     */ 
    /* fixnum precision, requiring a bignum */
    /* to hold the result.                  */
    /****************************************/

    Vm_Obj oc   = bnm_Alloc( (Vm_Unt)2, (Vm_Unt)0 );

    struct Bnm_Header_Rec128 xa;
    struct Bnm_Header_Rec128 xb;

    xa.physicalLength = (Vm_Unt)128;
    xb.physicalLength = (Vm_Unt)128;

    xa.private        = FALSE;
    xb.private        = FALSE;

    xa.is_a           = bnm_Type_Summary.builtin_class;
    xb.is_a           = bnm_Type_Summary.builtin_class;

    xa.length         = (Vm_Unt)1;
    xb.length         = (Vm_Unt)1;

    if (a < 0) {    xa.slot[0]    = -a; xa.sign = (Vm_Int)-1; }
    else {          xa.slot[0]    =  a; xa.sign = (Vm_Int) 1; }

    if (b < 0) {    xb.slot[0]    = -b; xb.sign = (Vm_Int)-1; }
    else {          xb.slot[0]    =  b; xb.sign = (Vm_Int) 1; }

    {   Bnm_P  c = vm_Loc(oc);
	add( c, (Bnm_P)&xa, (Bnm_P)&xb );
        vm_Dirty(oc);
        oc = maybeConvertToFixnum( oc, c );
    }

    return oc;
}
    
/************************************************************************/
/*-    sub -- subtract two bignums					*/
/************************************************************************/

static void
sub(
    Bnm_P c,
    Bnm_P a,
    Bnm_P b
) {
    int     sa     = (int) a->sign;
    int     sb     = (int) b->sign;
    int     signab = (sa << 1) +sb;
    switch (signab) {
    case POS_POS: if (magOrder(a,b) == LESS)   return subs(c,b,a,-1);
		  else                         return subs(c,a,b, 1);
    case POS_NEG:                              return adds(c,a,b, 1);
    case NEG_POS:                              return adds(c,a,b,-1);
    case NEG_NEG: if (magOrder(a,b) == LESS)   return subs(c,b,a, 1);
		  else                         return subs(c,a,b,-1);
    }
}

/************************************************************************/
/*-    bnm_Sub -- subtract two bignums					*/
/************************************************************************/

Vm_Obj
bnm_Sub(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Unt lena = BNM_P(oa)->length;
    Vm_Unt lenb = BNM_P(ob)->length;
    Vm_Unt lenc = (lena > lenb) ? lena+(Vm_Unt)1 : lenb+(Vm_Unt)1;
    Vm_Obj oc   = bnm_Alloc( lenc, (Vm_Unt)0 );

    Bnm_P  a;
    Bnm_P  b;
    Bnm_P  c;
    vm_Loc3( (void**)&a, (void**)&b, (void**)&c, oa, ob, oc );

    sub( c, a, b );
    vm_Dirty(oc);
    oc = maybeConvertToFixnum( oc, c );

    return oc;
}
    
/************************************************************************/
/*-    bnm_SubBI -- sub of bignum and fixnum				*/
/************************************************************************/

Vm_Obj
bnm_SubBI(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Unt lena = BNM_P(oa)->length;
    Vm_Unt lenc = lena+(Vm_Unt)1;
    Vm_Int b    = OBJ_TO_INT(ob);
    Vm_Obj oc   = bnm_Alloc( lenc, (Vm_Unt)0 );
    struct Bnm_Header_Rec128 xb;
    xb.private        = FALSE;
    xb.is_a           = bnm_Type_Summary.builtin_class;
    xb.physicalLength = (Vm_Unt)128;
    xb.length         = (Vm_Unt)1;

    if (b < 0) {    xb.slot[0]    = -b; xb.sign = (Vm_Int)-1; }
    else {          xb.slot[0]    =  b; xb.sign = (Vm_Int) 1; }

    {   Bnm_P  a;
	Bnm_P  c;
	vm_Loc2( (void**)&a, (void**)&c, oa, oc );

	sub( c, a, (Bnm_P)&xb );
        vm_Dirty(oc);
        oc = maybeConvertToFixnum( oc, c );
    }

    return oc;
}
    
/************************************************************************/
/*-    bnm_SubIB -- sub of fixnum and bignum				*/
/************************************************************************/

Vm_Obj
bnm_SubIB(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Unt lenb = BNM_P(ob)->length;
    Vm_Unt lenc = lenb+(Vm_Unt)1;
    Vm_Int a    = OBJ_TO_INT(oa);
    Vm_Obj oc   = bnm_Alloc( lenc, (Vm_Unt)0 );
    struct Bnm_Header_Rec128 xa;
    xa.private        = FALSE;
    xa.is_a           = bnm_Type_Summary.builtin_class;
    xa.physicalLength = (Vm_Unt)128;
    xa.length         = (Vm_Unt)1;

    if (a < 0) {    xa.slot[0]    = -a; xa.sign = (Vm_Int)-1; }
    else {          xa.slot[0]    =  a; xa.sign = (Vm_Int) 1; }

    {   Bnm_P  b;
	Bnm_P  c;
	vm_Loc2( (void**)&b, (void**)&c, ob, oc );

	sub( c, (Bnm_P)&xa, b );
        vm_Dirty(oc);
        oc = maybeConvertToFixnum( oc, c );
    }

    return oc;
}
    
/************************************************************************/
/*-    bnm_SubII -- subtract two fixnums				*/
/************************************************************************/

Vm_Obj
bnm_SubII(
    Vm_Int a,
    Vm_Int b
){
    /****************************************/
    /* This routine is normally called only */
    /* if the fixnum subtraction overflows  */ 
    /* fixnum precision, requiring a bignum */
    /* to hold the result.                  */
    /****************************************/

    Vm_Obj oc   = bnm_Alloc( (Vm_Unt)2, (Vm_Unt)0 );

    struct Bnm_Header_Rec128 xa;
    struct Bnm_Header_Rec128 xb;

    xa.private        = FALSE;
    xb.private        = FALSE;

    xa.is_a           = bnm_Type_Summary.builtin_class;
    xb.is_a           = bnm_Type_Summary.builtin_class;

    xa.physicalLength = (Vm_Unt)128;
    xb.physicalLength = (Vm_Unt)128;

    xa.length         = (Vm_Unt)1;
    xb.length         = (Vm_Unt)1;

    if (a < 0) {    xa.slot[0]    = -a; xa.sign = (Vm_Int)-1; }
    else {          xa.slot[0]    =  a; xa.sign = (Vm_Int) 1; }

    if (b < 0) {    xb.slot[0]    = -b; xb.sign = (Vm_Int)-1; }
    else {          xb.slot[0]    =  b; xb.sign = (Vm_Int) 1; }

    {   Bnm_P  c = vm_Loc(oc);
	sub( c, (Bnm_P)&xa, (Bnm_P)&xb );
        vm_Dirty(oc);
        oc = maybeConvertToFixnum( oc, c );
    }

    return oc;
}
    
/************************************************************************/
/*-    shift_roit_in_place -- in-place right-shift of bits in a bignum	*/
/************************************************************************/

static void
shift_roit_in_place(
    Bnm_P a,
    int   shiftBy
) {
    int len   = (int)a->length;
    int words = shiftBy >> VM_LOG2_INTBITS;	/* Words to shift by.		*/
    int rbits = shiftBy & (VM_INTBITS-1);	/* Remaining bits to shift by.	*/

#ifdef NOISY
printf("shift_roit_in_place/top: shiftBy d=%d\n",shiftBy);
printf("shift_roit_in_place/top: len d=%d\n",len);
printf("shift_roit_in_place/top: words d=%d\n",words);
printf("shift_roit_in_place/top: rbits d=%d\n",rbits);
printf("shift_roit_in_place/top: slot[0] x=%" VM_X "\n",a->slot[0]);
printf("shift_roit_in_place/top: slot[1] x=%" VM_X "\n",a->slot[1]);
print("a",a);
#endif
    /* Do whole-word part of shift, shifting zeros into upper words: */
    if (words) {
	int  i;
	for (i = 0;   i < len-words;   ++i)    a->slot[i] = a->slot[i+words];
	for (     ;   i < len      ;   ++i)    a->slot[i] =        (Vm_Unt)0;
    }
#ifdef NOISY
printf("shift_roit_in_place/mid: len d=%d\n",len);
printf("shift_roit_in_place/mid: slot[0] x=%" VM_X "\n",a->slot[0]);
printf("shift_roit_in_place/mid: slot[1] x=%" VM_X "\n",a->slot[1]);
print("a",a);
#endif

    /* Do fractional-word part of shift: */
    if (rbits) {
        int lbits = VM_INTBITS - rbits;	/* Complement of rbits.		*/
	Vm_Unt  v = (Vm_Unt) 0;	/* Overflow bits from previous word.	*/
	int     i;
	for    (i = len;   i --> 0;   ) {
	    Vm_Unt u   = a->slot[i];    /* Read current val of slot.	*/
	    a->slot[i] = (u >> rbits) | v;/* Construct new value of slot*/
	    v          = (u << lbits); 	/* Overflow bits shifted out.	*/
    }   }

    normalize( a );
#ifdef NOISY
printf("shift_roit_in_place/bot: len d=%d\n",(int)a->length);
printf("shift_roit_in_place/bot: slot[0] x=%" VM_X "\n",a->slot[0]);
printf("shift_roit_in_place/bot: slot[1] x=%" VM_X "\n",a->slot[1]);
print("a",a);
#endif
}

/************************************************************************/
/*-    shift_left_in_place -- in-place left-shift of bits in a bignum	*/
/************************************************************************/

#ifdef NOISY
static slipdebug = FALSE;
#endif
static void
shift_left_in_place(
    Bnm_P a,
    int   shiftBy
) {
    int words = shiftBy >> VM_LOG2_INTBITS;	/* Words to shift by.		*/
    int lbits = shiftBy & (VM_INTBITS-1);	/* Remaining bits to shift by.	*/
    int len   = ((int)a->length) + words +1;

    #if MUQ_IS_PARANOID
#ifdef NOISY
if(slipdebug)printf("shift_left_in_place: shiftBy d=%d\n",shiftBy);
if(slipdebug)printf("a->length d=%" VM_D "\n",a->length);
if(slipdebug)printf("a->physicalLength d=%" VM_D "\n",a->physicalLength);
if(slipdebug)printf("words d=%d\n",words);
if(slipdebug)printf("lbits d=%d\n",lbits);
if(slipdebug)printf("len d=%d\n",len);
#endif
    if (len-1 > (int)a->physicalLength) MUQ_FATAL("bnm:shift_left_in_place: internal err");
    #endif

    /* Do whole-word part of shift, shifting zeros into lower words: */
    if (words) {
	int  i;
#ifdef PRODUCTION
	for (i = len-2;   i >= words;   --i)    a->slot[i] = a->slot[i-words];
	for (         ;   i >=     0;   --i)    a->slot[i] =        (Vm_Unt)0;
#else
#ifdef NOISY
if(slipdebug)printf("doing whole-words part of shift...\n");
#endif
	for (i = len-2;   i >= words;   --i) {
	    a->slot[i] = a->slot[i-words];
#ifdef NOISY
if(slipdebug)printf("a->slot[%d] = a->slot[%d] x=%" VM_X "\n",i,i-words,a->slot[i]);
#endif
	}
	for (         ;   i >=     0;   --i) {
	    a->slot[i] =        (Vm_Unt)0;
#ifdef NOISY
if(slipdebug)printf("a->slot[%d] = 0\n",i);
#endif
	}
#endif
	a->length = (Vm_Unt)len-1;
    }

    /* Do fractional-word part of shift: */
    if (lbits) {
        int rbits = VM_INTBITS - lbits;	/* Complement of lbits.		*/
	Vm_Unt  v = (Vm_Unt) 0;	/* Overflow bits from previous word.	*/
	Vm_Unt  u = 0;		/* Initialized only to quiet compilers.	*/
	int     i;
#ifdef NOISY
if(slipdebug)printf("doing sub-word part of shift...\n");
#endif
	for    (i = 0;   i < len-1;  ++i) {
	    u          = a->slot[i];    /* Read current val of slot.	*/
#ifdef NOISY
if(slipdebug)printf("a->slot[%d] x=%" VM_X "\n",i,a->slot[i]);
#endif
	    a->slot[i] = (u << lbits) | v;/* Construct new value of slot*/
#ifdef NOISY
if(slipdebug)printf("a->slot[%d] set x=%" VM_X "\n",i,a->slot[i]);
#endif
	    v          = (u >> rbits); 	/* Overflow bits shifted out.	*/
        }

	/* Do final word, if any.  We do this in */
	/* slightly convoluted style to avoid    */
	/* signalling an error unless '1' bits   */
	/* are definitely shifting into missing  */
	/* words:				 */
	if (!v) {
	    a->length = (Vm_Unt)len-1;
	} else {
	    #if MUQ_IS_PARANOID
	    if (len > (int)a->physicalLength+1) MUQ_FATAL("bnm:shift_left_in_place: internal err b");
	    #endif
	    a->length = (Vm_Unt)len;
	    a->slot[i] = v;
#ifdef NOISY
if(slipdebug)printf("final a->slot[%d] x=%" VM_X "\n",i,a->slot[i]);
#endif
	}
    }

    normalize( a );
}

/************************************************************************/
/*-    shift_roit -- dynamic right-shift of bits in a bignum		*/
/************************************************************************/

static Vm_Obj
shift_roit(
    Vm_Obj oa,
    Vm_Int shiftBy
) {
    if (!shiftBy)   return bnm_Dup(oa);

    {   /* Allocate appropriately sized result object: */
	int words = shiftBy >> VM_LOG2_INTBITS;	/* Words to shift by.		*/
	int rbits = shiftBy & (VM_INTBITS-1);	/* Remaining bits to shift by.	*/
        int lena  = (int)BNM_P(oa)->length;
        int lenb  = lena - words;
	if (lenb <= 0) {
	    return bnm_Alloc( (Vm_Unt)1, (Vm_Unt)0 );
	} else {
	    Vm_Obj oc = bnm_Alloc( (Vm_Unt)lenb, (Vm_Unt)0 );
	    Bnm_P  a;
	    Bnm_P  c;
	    vm_Loc2( (void**)&a, (void**)&c, oa, oc );

	    /* Shift by nearest integral number of words: */
	    {   int  i;
		for (i = lenb;   i -->    0;   )   c->slot[i] = a->slot[i+words];
	    }

	    /* Shift by remaining number of bits (less than a wordlength): */
	    shift_roit_in_place( c, rbits );
            oc = maybeConvertToFixnum( oc, c );

/* buggo, still need to think about sign bits */
	    return   oc ;
	}
    }
}

/************************************************************************/
/*-    shift_left -- dynamic left-shift of bits in a bignum		*/
/************************************************************************/

static Vm_Obj
shift_left(
    Vm_Obj oa,
    Vm_Int shiftBy,
    Bnm_P  a
) {
    if (!shiftBy)   return bnm_Dup(oa);

    {   /* Allocate appropriately sized result object: */
	int words = shiftBy >> VM_LOG2_INTBITS;	/* Words to shift by.		*/
	int lbits = shiftBy & (VM_INTBITS-1);	/* Remaining bits to shift by.	*/
        int rbits = VM_INTBITS - lbits;		/* Complement of above.		*/
        int lena  = oa ? (int)BNM_P(oa)->length : 1;
        int lenc  = lena + words + 1;
	Vm_Obj oc = bnm_Alloc( (Vm_Unt)lenc, (Vm_Unt)0 );
	Bnm_P  c;
	vm_Loc2( (void**)&a, (void**)&c, oa, oc );

	/* Shift by nearest integral number of words: */
        {   int  i;
	    for (i = lena ;   i --> 0;   )   c->slot[i+words] = a->slot[i];
	    for (i = words;   i --> 0;   )   c->slot[i      ] =  (Vm_Unt)0;
	}

	/* Shift by remaining number of bits (less than a wordlength): */
	if (lbits) {
	    Vm_Unt v = (Vm_Unt) 0;	/* Overflow bits from previous word.	*/
            int    i;
	    for   (i = 0;   i < lenc;   ++i) {
		Vm_Unt u   = c->slot[i];        /* Read current val of slot.	*/
		c->slot[i] = (u << lbits) | v;	/* Construct new value of slot.	*/
		v          = (u >> rbits); 	/* Overflow bits shifted out.	*/
	    }
    	}
	c->length = lenc;
	normalize(c);
        oc = maybeConvertToFixnum( oc, c );

/* buggo, still need to think about sign bits */
	return   oc ;
    }
}

/************************************************************************/
/*-    bnm_Leftshift -- left-shift of bits in a bignum			*/
/************************************************************************/

Vm_Obj
bnm_Leftshift(
    Vm_Obj oa,
    Vm_Obj b
){
    Vm_Int shiftBy = OBJ_TO_INT(b);

    if (shiftBy < 0)   return shift_roit( oa, -shiftBy       );
    else               return shift_left( oa,  shiftBy, NULL );
}
    
/************************************************************************/
/*-    bnm_LeftshiftII -- left-shift a fixnum by a fixnum		*/
/************************************************************************/

Vm_Obj
bnm_LeftshiftII(
    Vm_Int a,
    Vm_Int shiftBy
){
    struct Bnm_Header_Rec128 xa;
    xa.private        = FALSE;
    xa.is_a           = bnm_Type_Summary.builtin_class;
    xa.physicalLength = (Vm_Unt)128;
    xa.length         = (Vm_Unt)1;

    if (a < 0) {    xa.slot[0]    = -a; xa.sign = (Vm_Int)-1; }
    else {          xa.slot[0]    =  a; xa.sign = (Vm_Int) 1; }

    return shift_left( OBJ_FROM_UNT(0),  shiftBy, (Bnm_P)&xa );
}
    
/************************************************************************/
/*-    bnm_Rightshift -- right-shift of bits in a bignum		*/
/************************************************************************/

Vm_Obj
bnm_Rightshift(
    Vm_Obj a,
    Vm_Obj b
){
    Vm_Int shiftBy = OBJ_TO_INT(b);
    if (shiftBy < 0)   return shift_left( a, -shiftBy, NULL );
    else               return shift_roit( a,  shiftBy       );
}
    
/************************************************************************/
/*-    bnm_VmuntBits -- compute number of significant bits in a Vm_Unt	*/
/************************************************************************/

int
bnm_VmuntBits(
    Vm_Unt u
) {
    int bits = 0;

    while (u & ~(Vm_Unt)0xFFFF) {  u >>= 16;	bits += 16; }
    if    (u & ~(Vm_Unt)0x00FF) {  u >>=  8;	bits +=  8; }
    if    (u & ~(Vm_Unt)0x000F) {  u >>=  4;	bits +=  4; }
    if    (u & ~(Vm_Unt)0x0003) {  u >>=  2;	bits +=  2; }
    if    (u & ~(Vm_Unt)0x0001) {  u >>=  1;	bits +=  1; }
    if    (u &  (Vm_Unt)0x0001) {           	bits +=  1; }

    return bits;
} 

/************************************************************************/
/*-    bits -- compute number of significant bits in a bignum		*/
/************************************************************************/

static int
bits(
    Bnm_P a
) {
    int n  = (int)a->length-1;
    while (!a->slot[n]) {
	if (!n)   return 0;
	--n;
    }
    return n*VM_INTBITS + bnm_VmuntBits( a->slot[n] );
}

/************************************************************************/
/*-    bnm_Bits -- compute number of significant bits in a bignum	*/
/************************************************************************/

int
bnm_Bits(
    Vm_Obj o
) {
    return bits( BNM_P(o) );
} 


/************************************************************************/
/*-    divmod -- static quotient+remainder computation			*/
/************************************************************************/

static void
divmod(
    Bnm_P protoQuotient,	/* Output: state irrelevant size relevant*/
    Bnm_P protoRemainder,	/* Output: state irrelevant size relevant*/
    Bnm_P shiftedDivisor,	/* Temp:   state irrelevant,size relevant*/
    Bnm_P dividend,		/* Input.  Not modified.		 */
    Bnm_P divisor		/* Input.  Not modified.		 */
) {
    /********************************************************/
    /* The simplest way to do division is to initialize a   */
    /* temporary r to the dividend, then repeatedly subtract*/
    /* the divisor from r until r is less than the divisor. */
    /*							    */
    /* When done, r is the remainder, and the count of the  */
    /* number of subtractions done is the quotient.	    */
    /*							    */
    /* That naive algorithm is too slow to be practical,    */
    /* of course, but if we at each step we subtract from   */
    /* r not the dividend, but instead 2**s * dividend, for */
    /* the largest practical value of 's' (and of course    */
    /* also bump the quotient by 2**s instead of 1), we	    */
    /* achieve a quite practical algorithm.  Multiplying    */
    /* by 2**s can of course be done just by left-shifting  */
    /* the dividend by s bits, a quick operation.	    */
    /*							    */
    /* We will implement this algorithm using a temporary   */
    /* variable 't' to hold 2**s * dividend.		    */
    /*							    */
    /* Our basic loop invariant here is thus:		    */
    /*   protoQuotient*divisor + protoRemainder == dividend */
    /*   (that is, q*b+r==a)				    */
    /* with additional minor loop invariants:		    */
    /* t == 2**s * divisor				    */
    /********************************************************/
#ifdef NOISY
static calls=0;
printf("divmod/top... ++calls d=%d\n",++calls);
print("divisor",divisor);
print("dividend",dividend);
#endif
    set( protoRemainder, dividend );
#ifdef NOISY
if (calls==8)print("protoRemainder",protoRemainder);
#endif
    {   int sq 	      = 1;	/* Sign of quotient, with dummy initial value.	*/
	int remainderbits = bits( protoRemainder );
	int divisorbits   = bits( divisor        );
	int s             = remainderbits - divisorbits;

	int shiftedDivisorbits;
#ifdef NOISY
if (calls==8)printf("sq d=%d\n",sq);
if (calls==8)printf("remainderbits d=%d\n",remainderbits);
if (calls==8)printf("divisorbits d=%d\n",divisorbits);
if (calls==8)printf("s d=%d\n",s);
#endif

	{   /* Figure sign sq for quotient.	*/
	    int     sa     = (int) dividend->sign;
	    int     sb     = (int) divisor ->sign;
	    int     signab = (sa << 1) +sb;
	    switch (signab) {
	    case NEG_NEG:
	    case POS_POS: sq =  1;	break;
	    case POS_NEG:
	    case NEG_POS: sq = -1;	break;
	    }
	}
#ifdef NOISY
if (calls==8)printf("sq d=%d\n",sq);
#endif

	/* Initialize word which will eventually be quotient: */
	zero(protoQuotient);
#ifdef NOISY
if (calls==8)print("protoQuotient",protoQuotient);
#endif
	protoQuotient->sign = (Vm_Int)sq;

	/* Initialize a temporary containing the varying multiple  */
	/* of the divisor which we keep subtracting off remainder: */
	zero(shiftedDivisor);
#ifdef NOISY
if (calls==8)print("zeroed shiftedDivisor",shiftedDivisor);
if (calls==8)printf("s d=%d\n",s);
#endif
	set( shiftedDivisor,divisor);
#ifdef NOISY
if (calls==8)print("shiftedDivisor = divisor",shiftedDivisor);
if (calls==8)printf("s d=%d\n",s);
if (calls==8)printf("shiftedDivisor->physicalLength d=%" VM_D "\n",shiftedDivisor->physicalLength);
if (calls==8)printf("shiftedDivisor->length d=%" VM_D "\n",shiftedDivisor->length);
if (calls==8)printf("dividend->physicalLength d=%" VM_D "\n",dividend->physicalLength);
if (calls==8)printf("dividend->length d=%" VM_D "\n",dividend->length);
slipdebug=(calls==8);
#endif
	shift_left_in_place( shiftedDivisor, s );
#ifdef NOISY
slipdebug=FALSE;
if (calls==8)print("shiftedDivisor <<= s",shiftedDivisor);
if (calls==8)printf("shiftedDivisor->physicalLength d=%" VM_D "\n",shiftedDivisor->physicalLength);
if (calls==8)printf("shiftedDivisor->length d=%" VM_D "\n",shiftedDivisor->length);
#endif
	shiftedDivisorbits   = bits( shiftedDivisor );
#ifdef NOISY
if (calls==8)printf("shiftedDivisor bits d=%d\n",shiftedDivisorbits);
#endif

	/* While protoRemainder > divisor.	*/
	while (magOrder(protoRemainder,divisor) == MORE) {
#ifdef NOISY
if (calls==8)printf("while protoRemainder > divisor...\n");
if (calls==8)print("protoRemainder",protoRemainder);
if (calls==8)print("divisor",divisor);
#endif

	    /* Find largest 's' we can use.	      	  */
	    /* While shiftedDivisor > protoRemainder: */
	    while (magOrder(shiftedDivisor,protoRemainder) == MORE) {
#ifdef NOISY
if (calls==8)printf("while shiftedDivisor > protoRemainder...\n");
if (calls==8)print("shiftedDivisor",shiftedDivisor);
if (calls==8)print("protoRemainder",protoRemainder);
#endif

		/* Divide shiftedDivisor by two:      */
		shift_roit_in_place(shiftedDivisor,1);
#ifdef NOISY
if (calls==8)print("shiftedDivisor >>= 1",shiftedDivisor);
#endif
		--shiftedDivisorbits;
#ifdef NOISY
if (calls==8)printf("--shiftedDivisorbits d=%d\n",shiftedDivisorbits);
#endif
		--s;
#ifdef NOISY
if (calls==8)printf("--s d=%d\n",s);
#endif
	    }

	    /* Subtract shiftedDivisor from protoRemainder,		*/
	    /* and correspondingly add 2**s to protoQuotient:	*/
#ifdef NOISY
if (calls==8)print("protoRemainder",protoRemainder);
if (calls==8)print("shiftedDivisor",shiftedDivisor);
#endif
	    sub_in_place( protoRemainder, shiftedDivisor );
#ifdef NOISY
if (calls==8)print("protoRemainder -= shiftedDivisor",protoRemainder);
if (calls==8)print("protoQuotient",protoQuotient);
if (calls==8)printf("s d=%d\n",s);
#endif
	    add_one_bit(  protoQuotient,  s              );
#ifdef NOISY
if (calls==8)print("protoQuotient += s",protoQuotient);
#endif

	    /* Update remainderbits to match new value:		*/
	    remainderbits = bits(protoRemainder);
#ifdef NOISY
if (calls==8)printf("remainderbits d=%d\n",remainderbits);
#endif

	    /* We may be able to shrink s by many bits at		*/	
	    /* this point, if protoRemainder just got very		*/	
	    /* small:					      	*/
	    {   int i = shiftedDivisorbits - remainderbits;
		if (i > 0) {
#ifdef NOISY
if (calls==8)print("shiftedDivisor",shiftedDivisor);
#endif
		    shift_roit_in_place( shiftedDivisor, i );
#ifdef NOISY
if (calls==8)printf("i d=%d\n",i);
if (calls==8)print("shiftedDivisor >>= i",shiftedDivisor);
#endif
		    shiftedDivisorbits = remainderbits;
	    }   }

	    s = shiftedDivisorbits - divisorbits;
	}

	/* Special case if remainder exactly equals divisor:	*/
#ifdef NOISY
if (calls==8)printf("Checking for special case of remainder == divisor: \n");
if (calls==8)print("protoQuotient",protoQuotient);
if (calls==8)print("protoRemainder",protoRemainder);
if (calls==8)print("divisor",divisor);
#endif
	if (magOrder(protoRemainder,divisor) == EQUAL) { 
#ifdef NOISY
if (calls==8)printf("They -are- equal...\n");
#endif
	    add_one_bit(protoQuotient,0);    /* Add 1 to quotient.	*/
#ifdef NOISY
if (calls==8)print("protoQuotient++",protoQuotient);
#endif
	    zero(protoRemainder);	     /* Zero remainder.		*/
#ifdef NOISY
if (calls==8)print("protoRemainder=0",protoRemainder);
#endif
	}
#ifdef NOISY
if (calls==8)printf("divmod DONE\n");
#endif
#ifdef HYPERPARANOID
/* Verify final result by other means: */
{
  struct Bnm_Header_Rec128 _u;
  struct Bnm_Header_Rec128 _v;
  _u.private         = FALSE;
  _v.private         = FALSE;
  _u.is_a            = bnm_Type_Summary.builtin_class;
  _v.is_a            = bnm_Type_Summary.builtin_class;
  _u.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  _v.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  mult((Bnm_P)&_u,protoQuotient,divisor);
  add((Bnm_P)&_v,(Bnm_P)&_u,protoRemainder);
  if (order((Bnm_P)&_v,dividend) != EQUAL) { 
printf("divmod result was INCORRECT\n");
print("dividend",dividend);
print("divisor",divisor);
print("protoRemainder",protoRemainder);
print("protoQuotient",protoQuotient);
print("_v",(Bnm_P)&_v);
exit(1);
  } else {
printf("divmod result CHECKS OUT OK\n");
  }  
}
#endif
    }
}

/************************************************************************/
/*-    bnm_Divmod -- integer division of two bignums			*/
/************************************************************************/

Vm_Obj			/* We return quotient as result.		*/
bnm_Divmod(
    Vm_Obj*    orp,	/* We return remainder via this pointer.	*/
    Vm_Obj     oa,	/* Dividend.					*/
    Vm_Obj     ob,	/* Divisor.					*/
    Bnm_P      dividend,/* NULL else use this instead of oa.		*/
    Bnm_P      divisor	/* NULL else use this instead of ob.		*/
){
    /* Catch divide by zero: */
    {   Bnm_P d = divisor;
	if (!d) d = (Bnm_P)vm_Loc(ob);
        if (d->length == (Vm_Unt)1   &&   d->slot[0] == (Vm_Unt)0) {
	    MUQ_WARN("bnm_Div: Cannot divide by zero");
    }   }

    {   /* Allocate bignums for quotient and remainder. */
	/* These also hold intermediate results.  Note  */
	/* that neither quotient nor remainder can be   */
	/* larger than dividend:                        */
	Vm_Obj oq;
        Vm_Obj or;
        Vm_Obj ot;
	if (!dividend) {
	    oq = bnm_Dup( oa );
	    or = bnm_Dup( oa );
	    ot = bnm_Dup( oa );
	} else {
	    oq = bnm_Alloc( (Vm_Unt)2, (Vm_Unt)0 );
	    or = bnm_Alloc( (Vm_Unt)2, (Vm_Unt)0 );
	    ot = bnm_Alloc( (Vm_Unt)2, (Vm_Unt)0 );
	    BNM_P(oq)->slot[0] = dividend->slot[0];
	    BNM_P(or)->slot[0] = dividend->slot[0];
	    BNM_P(ot)->slot[0] = dividend->slot[0];
	}

	{   /* If dividend (oa) is less than divisor (ob), then */
	    /* it is in fact the remainder, the quotient is 	*/
	    /* zero, and we're done:				*/
	    Bnm_P protoQuotient; /* Will be quotient when done.	*/
	    Bnm_P protoRemainder;/* Will be remainder when done.*/
	    vm_Loc4(
		(void**)&dividend,
		(void**)&divisor,
		(void**)&protoQuotient,
		(void**)&protoRemainder,
		oa, ob, oq, or
	    );
	    if (magOrder(dividend,divisor) == LESS) {
		oq = maybeConvertToFixnum( oq, protoQuotient  );
		or = maybeConvertToFixnum( or, protoRemainder );
		*orp = or;
		return oq;
	    }

	    /* If divisor is 1, then dividend (oa) is the	*/
	    /* quotient, and remainder  is 0, and we're home	*/
	    /*  free again:					*/
	    if (divisor->length == 1   &&   divisor->slot[0] == (Vm_Unt)1) {
		oq = maybeConvertToFixnum( oq, protoQuotient  );
		or = maybeConvertToFixnum( or, protoRemainder );
		*orp = oq;
		return or;
	    }

	    /*************************************/
	    /* Oh well, actual work to do, then. */
	    /* But we can always delegate! :) :) */
	    /*************************************/
	    {	Bnm_P  shiftedDivisor;
		vm_Loc5(
		    (void**)&dividend,
		    (void**)&divisor,
		    (void**)&protoQuotient,
		    (void**)&protoRemainder,
		    (void**)&shiftedDivisor,
		    oa, ob, oq, or, ot
		);
		divmod(
		    protoQuotient,
		    protoRemainder,
		    shiftedDivisor,
		    dividend,
		    divisor
		);
    	    }

	    oq = maybeConvertToFixnum( oq, protoQuotient  );
	    or = maybeConvertToFixnum( or, protoRemainder );
	    *orp = or;
        }

        return oq;
    }

    /********************************************************************/
    /* Possible improvements:						*/
    /*									*/
    /* Use stack-allocated temps instead of heap-allocated temps for	*/
    /* small, common size ranges.					*/
    /********************************************************************/
}
    
/************************************************************************/
/*-    bnm_Mod -- remainder after division of two bignums		*/
/************************************************************************/

Vm_Obj
bnm_Mod(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Obj or;
    bnm_Divmod( &or, oa, ob, NULL, NULL ); /* Ignore returned quotient.	*/
    return or;

    /********************************************************************/
    /* Possible improvements:						*/
    /*									*/
    /* Write specialized fn instead of using Divmod.			*/
    /********************************************************************/
}
    
/************************************************************************/
/*-    bnm_ModBI -- mod of bignum and fixnum				*/
/************************************************************************/

Vm_Obj
bnm_ModBI(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Int b    = OBJ_TO_INT(ob);
    struct Bnm_Header_Rec128 xb;
    xb.private        = FALSE;
    xb.is_a           = bnm_Type_Summary.builtin_class;
    xb.physicalLength = (Vm_Unt)128;
    xb.length         = (Vm_Unt)1;

    if (b < 0) {    xb.slot[0]    = -b; xb.sign = (Vm_Int)-1; }
    else {          xb.slot[0]    =  b; xb.sign = (Vm_Int) 1; }

    {   Vm_Obj or;
        bnm_Divmod(
	    &or,		/* We return remainder via this pointer.*/
	    oa,			/* Dividend.				*/
	    OBJ_FROM_INT(0),	/* Divisor.				*/
	    NULL,		/* NULL else use this instead of oa.	*/
	    (Bnm_P)&xb		/* NULL else use this instead of ob.	*/
	);
	return or;
    }
}
    
/************************************************************************/
/*-    bnm_ModIB -- mod of fixnum and bignum				*/
/************************************************************************/

Vm_Obj
bnm_ModIB(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Int a    = OBJ_TO_INT(oa);
    struct Bnm_Header_Rec128 xa;
    xa.private        = FALSE;
    xa.is_a           = bnm_Type_Summary.builtin_class;
    xa.physicalLength = (Vm_Unt)128;
    xa.length         = (Vm_Unt)1;

    if (a < 0) {    xa.slot[0]    = -a; xa.sign = (Vm_Int)-1; }
    else {          xa.slot[0]    =  a; xa.sign = (Vm_Int) 1; }

    {   Vm_Obj or;
        bnm_Divmod(
	    &or,		/* We return remainder via this pointer.*/
	    OBJ_FROM_INT(0),	/* Dividend.				*/
	    ob,			/* Divisor.				*/
	    (Bnm_P)&xa,		/* NULL else use this instead of oa.	*/
	    NULL		/* NULL else use this instead of ob.	*/
	);
	return or;
    }
}
    
/************************************************************************/
/*-    bnm_Div -- quotient after division of two bignums		*/
/************************************************************************/

Vm_Obj
bnm_Div(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Obj or;
    return bnm_Divmod( &or, oa, ob, NULL, NULL );
}
    
/************************************************************************/
/*-    bnm_DivBI -- div of bignum and fixnum				*/
/************************************************************************/

Vm_Obj
bnm_DivBI(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Int b    = OBJ_TO_INT(ob);
    struct Bnm_Header_Rec128 xb;
    xb.private        = FALSE;
    xb.is_a           = bnm_Type_Summary.builtin_class;
    xb.physicalLength = (Vm_Unt)128;
    xb.length         = (Vm_Unt)1;

    if (b < 0) {    xb.slot[0]    = -b; xb.sign = (Vm_Int)-1; }
    else {          xb.slot[0]    =  b; xb.sign = (Vm_Int) 1; }

    {   Vm_Obj junque;
        return bnm_Divmod(
	    &junque,		/* We return remainder via this pointer.*/
	    oa,			/* Dividend.				*/
	    OBJ_FROM_INT(0),	/* Divisor.				*/
	    NULL,		/* NULL else use this instead of oa.	*/
	    (Bnm_P)&xb		/* NULL else use this instead of ob.	*/
	);
    }
}
    
/************************************************************************/
/*-    bnm_DivIB -- div of fixnum and bignum				*/
/************************************************************************/

Vm_Obj
bnm_DivIB(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Int a    = OBJ_TO_INT(oa);
    struct Bnm_Header_Rec128 xa;
    xa.private        = FALSE;
    xa.is_a           = bnm_Type_Summary.builtin_class;
    xa.physicalLength = (Vm_Unt)128;
    xa.length         = (Vm_Unt)1;

    if (a < 0) {    xa.slot[0]    = -a; xa.sign = (Vm_Int)-1; }
    else {          xa.slot[0]    =  a; xa.sign = (Vm_Int) 1; }

    {   Vm_Obj junque;
        return bnm_Divmod(
	    &junque,		/* We return remainder via this pointer.*/
	    OBJ_FROM_INT(0),	/* Dividend.				*/
	    ob,			/* Divisor.				*/
	    (Bnm_P)&xa,		/* NULL else use this instead of oa.	*/
	    NULL		/* NULL else use this instead of ob.	*/
	);
    }
}
    
/************************************************************************/
/*-    bin2dec								*/
/************************************************************************/

static Vm_Uch*
bin2dec(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Bnm_P a
) {
    /********************************************************************/
    /* Convert bignum to decimal ascii for printout, cursing under	*/
    /* our breath the ape who first decided that counting on one's	*/
    /* fingers meant including thumbs.					*/
    /*									*/
    /* To somewhat reduce the amount of bignum thrashing needed, we	*/
    /* lop off billion-size chunks (a value guaranteed to fit in a	*/
    /* Vm_Unt whether we're using 32-bit or 64-bit Vm_Unts) and	then	*/
    /* crank out sets of nine digits using single-precision ops.	*/
    /********************************************************************/
    Vm_Uch* t    = buf;

    struct Bnm_Header_Rec128 protoQuotient;
    struct Bnm_Header_Rec128 protoRemainder;
    struct Bnm_Header_Rec128 shiftedDivisor;
    struct Bnm_Header_Rec128 dividend;
    struct Bnm_Header_Rec    divisor;
#ifdef NOISY
printf("bin2dec/top...\n");
print("bin2dec: input a",a);
#endif

    /* Special-case zero: */
    if (a->length==1 && !a->slot[0]) {
	buf[0] =  '0';
	buf[1] = '\0';
#ifdef NOISY
printf("bin2dec/aaa...\n");
#endif
	return buf+1;
    }

    protoQuotient.private         = FALSE;
    protoRemainder.private        = FALSE;
    shiftedDivisor.private        = FALSE;
    dividend.private              = FALSE;
    divisor.private               = FALSE;

    protoQuotient.is_a            = bnm_Type_Summary.builtin_class;
    protoRemainder.is_a           = bnm_Type_Summary.builtin_class;
    shiftedDivisor.is_a           = bnm_Type_Summary.builtin_class;
    dividend.is_a                 = bnm_Type_Summary.builtin_class;
    divisor.is_a                  = bnm_Type_Summary.builtin_class;

    protoQuotient.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
    protoRemainder.physicalLength = (Vm_Unt)MAX_BNM_BIN2DEC;
    shiftedDivisor.physicalLength = (Vm_Unt)MAX_BNM_BIN2DEC;
    dividend.physicalLength       = (Vm_Unt)MAX_BNM_BIN2DEC;
    divisor.physicalLength        = (Vm_Unt)1;
#ifdef NOISY
printf("bin2dec/bbb...\n");
#endif

    zero( (Bnm_P) &protoQuotient  );
    zero( (Bnm_P) &protoRemainder );
    zero( (Bnm_P) &shiftedDivisor );
    zero( (Bnm_P) &dividend       );
    zero( (Bnm_P) &divisor        );
#ifdef NOISY
printf("bin2dec/ccc...\n");
#endif

    divisor.length                = (Vm_Unt)1;
    divisor.slot[0]               = (Vm_Unt)1000000000;
#ifdef NOISY
printf("bin2dec/ddd...\n");
#endif

    if (a->length > MAX_BNM_BIN2DEC) {
	MUQ_WARN("bnm:bin2dec: Number too large to convert to decimal with current implementation.");
    }
#ifdef NOISY
printf("bin2dec/eee...\n");
#endif

    /* Over all nine-decimal-digit chunks */
    /* in 'a', least significant first:   */
    set( (Bnm_P)&dividend, a );
    while (bits((Bnm_P)&dividend)) {

        Vm_Unt chunk;
#ifdef NOISY
printf("bin2dec/luptop...\n");
#endif

	/* Don't overflow output buffer: */
	if (t +11 >= lim) {	/* 11 == nine digits + minus-sign + null	*/
#ifdef NOISY
printf("bin2dec/fff...\n");
#endif
	    MUQ_WARN("bnm:bin2dec: Number overflows provided output buffer.");
        }

	/* Get next nine-digit chunk of number: */
#ifdef NOISY
printf("bin2dec/ggg...\n");
#endif
        if (dividend.length == 1  &&  dividend.slot[0] < (Vm_Unt)1000000000) {
#ifdef NOISY
printf("bin2dec/hhh...\n");
#endif
	    /* Only one chunk left, no multiprecision stuff needed: */
	    chunk = dividend.slot[0];
	    dividend.slot[0] = (Vm_Unt)0;
	} else {
#ifdef NOISY
printf("bin2dec/iii...\n");
print("dividend",(Bnm_P)&dividend);
print("divisor" ,(Bnm_P)&divisor );
zero( (Bnm_P) &protoQuotient  );
zero( (Bnm_P) &protoRemainder );
zero( (Bnm_P) &shiftedDivisor );
#endif
	    /* Divide remaining number by a billion,  */
	    /* leaving next chunk as remainder and    */
	    /* remaining work after that as quotient: */
	    divmod(
		(Bnm_P)&protoQuotient,
		(Bnm_P)&protoRemainder,
		(Bnm_P)&shiftedDivisor,
		(Bnm_P)&dividend,
		(Bnm_P)&divisor
	    );
#ifdef NOISY
printf("bin2dec/jjj...\n");
#endif
	    set( (Bnm_P)&dividend, (Bnm_P)&protoQuotient );
	    chunk = protoRemainder.slot[0];
	}
#ifdef NOISY
printf("bin2dec/kkk...\n");
#endif

	/* Break out nine digits: */
	{    Vm_Unt rest;
	     Vm_Unt this;

#ifdef NOISY
printf("bin2dec/lll...\n");
#endif
	     rest=chunk/10; this=chunk-(rest*10); chunk=rest; *t++='0'+this;
	     rest=chunk/10; this=chunk-(rest*10); chunk=rest; *t++='0'+this;
	     rest=chunk/10; this=chunk-(rest*10); chunk=rest; *t++='0'+this;

	     rest=chunk/10; this=chunk-(rest*10); chunk=rest; *t++='0'+this;
	     rest=chunk/10; this=chunk-(rest*10); chunk=rest; *t++='0'+this;
	     rest=chunk/10; this=chunk-(rest*10); chunk=rest; *t++='0'+this;

	     rest=chunk/10; this=chunk-(rest*10); chunk=rest; *t++='0'+this;
	     rest=chunk/10; this=chunk-(rest*10); chunk=rest; *t++='0'+this;
	     rest=chunk/10; this=chunk-(rest*10); chunk=rest; *t++='0'+this;
#ifdef NOISY
printf("bin2dec/mmm...\n");
#endif
	}	     
    }
#ifdef NOISY
printf("bin2dec/lupbot...\n");
#endif

    /* Suppress leading zeros: */
    while (&t[-1] > buf  &&  t[-1]=='0')   --t;
#ifdef NOISY
printf("bin2dec/nnn...\n");
#endif

    /* Add minus sign if needed: */
    if (a->sign == (Vm_Int)-1)   *t++ = '-';
#ifdef NOISY
printf("bin2dec/ooo...\n");
#endif

    /* Deposit trailing nul: */
    *t = '\0';
#ifdef NOISY
printf("bin2dec/ppp...\n");
#endif

    /* Reverse buf contents to conform to */
    /* most-significant-first convention: */
    {   Vm_Uch* s = buf;
	Vm_Uch* u = t-1;
        for (;   s < u;   ++s,--u) {
	    Vm_Uch c = *s;
	    *s       = *u;
	    *u       =  c;
#ifdef NOISY
printf("bin2dec/qqq...\n");
#endif
    }	}

#ifdef NOISY
printf("bin2dec/zzz...\n");
#endif
    return t;
}

/************************************************************************/
/*-    dec2bin								*/
/************************************************************************/

#define MAX_BNM_DEC2BIN 128
BNM_HEADER_REC(Bnm_Header_RecDec2Bin,MAX_BNM_DEC2BIN);

static Vm_Obj
dec2bin(
    Vm_Uch* buf
) {
    /********************************************************************/
    /* Convert decimal ascii to bignum, inverse of bin2dec.		*/
    /*									*/
    /* To somewhat reduce the amount of bignum thrashing needed, we	*/
    /* lop off billion-size chunks (a value guaranteed to fit in a	*/
    /* Vm_Unt whether we're using 32-bit or 64-bit Vm_Unts) and	then	*/
    /* crank out sets of nine digits using single-precision ops.	*/
    /********************************************************************/

    Vm_Int  resultSign = (Vm_Int)1;

    struct Bnm_Header_RecDec2Bin result;
    struct Bnm_Header_RecDec2Bin tmp;
    struct Bnm_Header_Rec        billion;


    result .private        = FALSE;
    tmp    .private        = FALSE;
    billion.private        = FALSE;

    result .is_a           = bnm_Type_Summary.builtin_class;
    tmp    .is_a           = bnm_Type_Summary.builtin_class;
    billion.is_a           = bnm_Type_Summary.builtin_class;

    result .physicalLength = (Vm_Unt)MAX_BNM_DEC2BIN;
    tmp    .physicalLength = (Vm_Unt)MAX_BNM_DEC2BIN;
    billion.physicalLength = (Vm_Unt)1;

    zero( (Bnm_P) &result  );
    zero( (Bnm_P) &tmp     );
    zero( (Bnm_P) &billion );



    /* Note and discard any leading minus sign: */
    if (*buf == '-') {
	resultSign = (Vm_Int)-1;  
	++buf;
    }



    /* Over all nine-decimal-digit chunks */
    /* in 'a', most significant first:    */
    {

        /* First chunk is a special case, */
        /* may not have a full 9 digits:  */
	Vm_Uch* t    = buf;
	Vm_Unt chunk = (Vm_Unt)0;
	Vm_Uch c;
	int    lenmod9  = strlen(buf) % 9;
	while (lenmod9 --> 0) {
	    c = *t++; 	chunk = chunk*10 + (c-'0');
	}
	result.length = 1;
	result.slot[0]= chunk;


	/* Guaranteed able to do rest */
	/* in full nine-digit chunks: */
	while (*t) {

	    /* Grab a nine-digit chunk of input: */
	    chunk = (Vm_Unt)0;

	    c = *t++; 	chunk = chunk*10 + (c-'0');
	    c = *t++; 	chunk = chunk*10 + (c-'0');
	    c = *t++; 	chunk = chunk*10 + (c-'0');

	    c = *t++; 	chunk = chunk*10 + (c-'0');
	    c = *t++; 	chunk = chunk*10 + (c-'0');
	    c = *t++; 	chunk = chunk*10 + (c-'0');

	    c = *t++; 	chunk = chunk*10 + (c-'0');
	    c = *t++; 	chunk = chunk*10 + (c-'0');
	    c = *t++; 	chunk = chunk*10 + (c-'0');



	    /* Don't overflow result: */
	    if (result.length == result.physicalLength) {
		MUQ_WARN("bnm:dec2bin: Input number too large to convert with current implementation");
	    }

	    /* Multiply previously accumulated result by a billion: */
	    billion.slot[0] = (Vm_Unt)1000000000;
	    zero( (Bnm_P)&tmp                                     );
	    mult( (Bnm_P)&tmp,    (Bnm_P)&result, (Bnm_P)&billion );

	    /* Add in new chunk: */
	    billion.slot[0] = chunk;
	    adds( (Bnm_P)&result, (Bnm_P)&tmp, (Bnm_P)&billion, resultSign );
	}
    }


    /* Set sign of result: */
    result.sign = resultSign;

    
    {   /* Allocate return number: */
	Vm_Obj oc = bnm_Alloc( result.length, (Vm_Unt)0 );

	/* Copy result into return number: */
	Bnm_P   c = BNM_P(oc);
	set(    c, (Bnm_P)&result );
#ifdef NOISY
print("dec2bin: result c",c);
printf("c p=%p",c);
printf("c->length d=%" VM_D "\n",c->length);
printf("oc x=%" VM_X "\n",oc);
#endif

	return oc;
    }	
}

/************************************************************************/
/*-    trulyRandomInteger -- 						*/
/************************************************************************/

static void
trulyRandomInteger(
    Bnm_P  p,
    Vm_Unt bits
) {
    /* Handle case where result needs a bignum: */
    Vm_Unt words   = bits >> VM_LOG2_INTBITS;
    Vm_Unt oddbits = bits & (((Vm_Unt)1 << VM_LOG2_INTBITS)-1);
    if (oddbits)  ++words;
    if (words > p->physicalLength) {
	MUQ_WARN("trulyRandomInteger: words > p->physicalLength?!\n");
    }
    {   /* Fill in as many pairs of words as possible in result: */
	Vm_Int i;
	for (i = 0;   i < words-1;  i += 2) {
	    Vm_Unt u;
	    Vm_Unt v = obj_TrueRandom( & u );
	    p->slot[i  ] = u;
	    p->slot[i+1] = v;
	}

	/* Fill in remaining odd word in result, if any: */
	if (words & 1) {
	    Vm_Unt v = obj_TrueRandom( NULL );
	    p->slot[words-1] = v;
	}

	/* Mask off any excess bits filled in: */
	if (oddbits) {
	    p->slot[words-1] &= (((Vm_Unt)1 << oddbits)-1);
	}
	p->length = words;

	normalize(p);
    }
}

/************************************************************************/
/*-    bnm_TrulyRandomInteger -- 					*/
/************************************************************************/

Vm_Obj
bnm_TrulyRandomInteger(
    Vm_Unt bits
) {
    if (bits <= (VM_INTBITS-OBJ_INT_SHIFT)-1) {

        /* Handle case where result fits in a fixnum: */
	Vm_Unt u = obj_TrueRandom( NULL );
	u       &= (((Vm_Unt)1 << bits)-1);
	return OBJ_FROM_UNT(u);

    } else {

        /* Handle case where result needs a bignum: */
	Vm_Unt words   = bits >> VM_LOG2_INTBITS;
	Vm_Unt oddbits = bits & (((Vm_Unt)1 << VM_LOG2_INTBITS)-1);
	if (oddbits)  ++words;
	if (words > MAX_BIGNUM) {
	    MUQ_WARN("bnm_TrulyRandomInteger: %d-bit integers not supported.\n",bits);
	}
	{   /* Allocate bignum to hold result: */
	    Vm_Obj o = bnm_Alloc( words, (Vm_Unt)0 );
	    Bnm_P  p = BNM_P(o);

#ifdef OLD
	    /* Fill in as many pairs of words as possible in result: */
	    Vm_Int i;
	    for (i = 0;   i < words-1;  i += 2) {
		Vm_Unt u;
		Vm_Unt v = obj_TrueRandom( & u );
		p->slot[i  ] = u;
		p->slot[i+1] = v;
	    }

	    /* Fill in remaining odd word in result, if any: */
	    if (words & 1) {
		Vm_Unt v = obj_TrueRandom( NULL );
		p->slot[words-1] = v;
	    }

	    /* Mask off any excess bits filled in: */
	    if (oddbits) {
		p->slot[words-1] &= (((Vm_Unt)1 << oddbits)-1);
	    }

	    normalize(p);
#else
	    trulyRandomInteger( p, bits );
#endif

	    return o;
	}
    }
}

/************************************************************************/
/*-    bnm_Logand -- bitwise AND of two bignums				*/
/************************************************************************/

Vm_Obj
bnm_Logand(
    Vm_Obj oa,
    Vm_Obj ob,
    Bnm_P  b
){
    int    len_a = BNM_P(oa)->length;
    int    len_b = ob ? BNM_P(ob)->length : 1;
    int    len_c = (len_a > len_b) ? len_a : len_b;
    int    minab = (len_a < len_b) ? len_a : len_b;
    Vm_Obj oc    = bnm_Alloc( len_c, (Vm_Unt)0 );
    Bnm_P  a;
    Bnm_P  c;
    vm_Loc3( (void**)&a, (void**)&b, (void**)&c, oa, ob, oc );

    {   int  i;
        for (i = len_c-1;   i >= minab;   --i) {
	    c->slot[i] = (Vm_Unt)0;
     	}
        for (           ;   i >= 0    ;   --i) {
	    c->slot[i] = a->slot[i] & b->slot[i];
     	}
	normalize(c);
    }

    /* Buggo?  Currently, result is always positive. */
    oc = maybeConvertToFixnum( oc, c );
    return oc;
}
    
/************************************************************************/
/*-    bnm_LogandBI -- bitwise AND of bignum and fixnum			*/
/************************************************************************/

Vm_Obj
bnm_LogandBI(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Int b    = OBJ_TO_INT(ob);

    struct Bnm_Header_Rec128 xb;
    xb.private        = FALSE;
    xb.is_a           = bnm_Type_Summary.builtin_class;
    xb.physicalLength = (Vm_Unt)128;
    xb.length         = (Vm_Unt)1;

    if (b < 0) {    xb.slot[0]    = -b; xb.sign = (Vm_Int)-1; }
    else {          xb.slot[0]    =  b; xb.sign = (Vm_Int) 1; }

    return bnm_Logand( oa, OBJ_FROM_INT(0), (Bnm_P)&xb );
}
    
/************************************************************************/
/*-    bnm_Logior -- bitwise OR of two bignums				*/
/************************************************************************/

Vm_Obj
bnm_Logior(
    Vm_Obj oa,
    Vm_Obj ob,
    Bnm_P  b
){
    int    len_a = BNM_P(oa)->length;
    int    len_b = ob ? BNM_P(ob)->length : 1;
    int    len_c = (len_a > len_b) ? len_a : len_b;
    int    minab = (len_a < len_b) ? len_a : len_b;
    Vm_Obj oc    = bnm_Alloc( len_c, (Vm_Unt)0 );
    Bnm_P  a;
    Bnm_P  c;
    vm_Loc3( (void**)&a, (void**)&b, (void**)&c, oa, ob, oc );

    {   int  i;
        if (len_a < len_b) {
	    for (i = len_c-1;   i >= minab;   --i) {
		c->slot[i] = b->slot[i];
	    }
	} else {
	    for (i = len_c-1;   i >= minab;   --i) {
		c->slot[i] = a->slot[i];
	    }
	}
        for (               ;   i >= 0    ;   --i) {
	    c->slot[i] = a->slot[i] | b->slot[i];
     	}
	normalize(c);
    }
    oc = maybeConvertToFixnum( oc, c );
    /* Buggo?  Currently, result is always positive. */
    return oc;
}
    
/************************************************************************/
/*-    bnm_LogiorBI -- bitwise OR of bignum and fixnum			*/
/************************************************************************/

Vm_Obj
bnm_LogiorBI(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Int b    = OBJ_TO_INT(ob);

    struct Bnm_Header_Rec128 xb;
    xb.private        = FALSE;
    xb.is_a           = bnm_Type_Summary.builtin_class;
    xb.physicalLength = (Vm_Unt)128;
    xb.length         = (Vm_Unt)1;

    if (b < 0) {    xb.slot[0]    = -b; xb.sign = (Vm_Int)-1; }
    else {          xb.slot[0]    =  b; xb.sign = (Vm_Int) 1; }

    return bnm_Logior( oa, OBJ_FROM_INT(0), (Bnm_P)&xb );
}
    
/************************************************************************/
/*-    bnm_Logxor -- bitwise exclusive-or of two bignums		*/
/************************************************************************/

Vm_Obj
bnm_Logxor(
    Vm_Obj oa,
    Vm_Obj ob,
    Bnm_P  b
){
    int len_a = (int)BNM_P(oa)->length;
    int len_b = (int)(ob ? BNM_P(ob)->length : 1);
    int len_c = (int)((len_a > len_b) ? len_a : len_b);
    int minab = (int)((len_a < len_b) ? len_a : len_b);
    Vm_Obj oc = bnm_Alloc( len_c, (Vm_Unt)0 );
    Bnm_P  a;
    Bnm_P  c;
    vm_Loc3( (void**)&a, (void**)&b, (void**)&c, oa, ob, oc );

    {   int  i;
        if (len_a < len_b) {
	    for (i = len_c-1;   i >= minab;   --i) {
		c->slot[i] = b->slot[i];
	    }
	} else {
	    for (i = len_c-1;   i >= minab;   --i) {
		c->slot[i] = a->slot[i];
	    }
	}
        for (               ;   i >= 0    ;   --i) {
	    c->slot[i] = a->slot[i] ^ b->slot[i];
     	}
	normalize(c);
    }
    oc = maybeConvertToFixnum( oc, c );
    /* Buggo?  Currently, result is always positive. */
    return oc;
}
    
/************************************************************************/
/*-    bnm_LogxorBI -- bitwise XOR of bignum and fixnum			*/
/************************************************************************/

Vm_Obj
bnm_LogxorBI(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Int b    = OBJ_TO_INT(ob);

    struct Bnm_Header_Rec128 xb;
    xb.private        = FALSE;
    xb.is_a           = bnm_Type_Summary.builtin_class;
    xb.physicalLength = (Vm_Unt)128;
    xb.length         = (Vm_Unt)1;

    if (b < 0) {    xb.slot[0]    = -b; xb.sign = (Vm_Int)-1; }
    else {          xb.slot[0]    =  b; xb.sign = (Vm_Int) 1; }

    return bnm_Logxor( oa, OBJ_FROM_INT(0), (Bnm_P)&xb );
}
    
/************************************************************************/
/*-    bnm_Lognot -- bitwise negation of a bignum			*/
/************************************************************************/

Vm_Obj
bnm_Lognot(
    Vm_Obj oa
){
    Vm_Unt len_a = BNM_P(oa)->length;
    Vm_Unt len_c = len_a;
    Vm_Obj oc    = bnm_Alloc( len_c, (Vm_Unt)0 );
    Bnm_P  a;
    Bnm_P  c;
    vm_Loc2( (void**)&a, (void**)&c, oa, oc );

    {   int  i;
        for (i = len_c;   i --> 0    ;   ) {
	    c->slot[i] = ~a->slot[i];
     	}
	normalize(c);
    }
    c->sign = -a->sign;
    /* Buggo?  Currently, result is always positive. */
    return oc;
}
    
/************************************************************************/
/*-    egcd -- static egcd						*/
/************************************************************************/

static void
egcd(
    Bnm_P x,	/* Input, and gcd is returned here.			*/
    Bnm_P y,	/* Input, DESTROYED DURING COMPUTATION.			*/

    Bnm_P g,	/* Temp.						*/
    Bnm_P t,	/* Scratch -- could drop if we had 2-arg add & sub.	*/

    Bnm_P u,	/* Temp.						*/
    Bnm_P v,	/* Temp.						*/

    Bnm_P A,	/* Temp.						*/
    Bnm_P B,	/* Temp.						*/
    Bnm_P C,	/* Temp, and extended return value.			*/
    Bnm_P D	/* Temp, and extended return value.			*/
){
    /********************************************************************/
    /*  			Theory of Operation			*/
    /*									*/
    /* The Extended Euclid's Greatest Common Divisor function differs	*/
    /* from the vanilla version in that we return not only the gcd of	*/
    /* input args (x,y), but also C,D such that x*C+y*D==gcd -- these	*/
    /* auxilliary return values are often handy.			*/
    /*									*/
    /* This fn follows algorithm 14.61 in Menezes' Handbook of Applied	*/
    /* Cryptography.  They don't really explain the algorithm, and I	*/
    /* won't venture to do so either *wrygrin*.				*/
    /********************************************************************/
#ifdef NOISY
printf("egcd/aaa: inputs\n");
print("x",x);
print("y",y);
#endif

    /* Not sure what standard approach is for handling negative numbers:*/
    /* Gcd is commonly defined only for nonnegatives.  For now we'll	*/
    /* ignore the sign:							*/
    x->sign = (Vm_Unt)1;
#ifdef NOISY
printf("egcd/bbb\n");
#endif
    y->sign = (Vm_Unt)1;
#ifdef NOISY
printf("egcd/ccc\n");
#endif

    /* Set g=1: */
    unit(g);
#ifdef NOISY
printf("egcd/ddd\n");
print("g",g);
#endif

    /* If x==0 or y==0, return 1: */
    if ((int)x->length == 1  &&  !x->slot[0]) {   set(x,g); zero(C); zero(D); return; }
#ifdef NOISY
printf("egcd/eee\n");
#endif
    if ((int)y->length == 1  &&  !y->slot[0]) {   set(x,g); zero(C); zero(D); return; }
#ifdef NOISY
printf("egcd/fff\n");
#endif

    /* Drop (and tabulate) common powers of two: */
    while ( !((int)x->slot[0] & 1)	/* While both x and	*/
    &&	    !((int)y->slot[0] & 1)	/* and y are even	*/
    ) {
#ifdef NOISY
printf("egcd/ggg\n");
#endif
	shift_roit_in_place( x, 1 );	
#ifdef NOISY
print("x",x);
#endif
	shift_roit_in_place( y, 1 );	
#ifdef NOISY
print("y",y);
#endif
	shift_left_in_place( g, 1 );
#ifdef NOISY
print("g",g);
#endif
    }
    /* Could change above to shift by more than one bit at a time.	*/
    /* Not likely to prove a frequent win in practice though, I'd guess.*/


    /* Set u=x v=y A=1 B=0 C=0 D=1: */
    set(u,x);
#ifdef NOISY
print("u set to x",u);
print("egcd: y",y);
printf("egcd: v->length d=%" VM_D "\n",v->length);
printf("egcd: v->physicalLength d=%" VM_D "\n",v->physicalLength);
printf("egcd: y->length d=%" VM_D "\n",y->length);
printf("egcd: y->physicalLength d=%" VM_D "\n",y->physicalLength);
#endif
    set(v,y);
#ifdef NOISY
print("v set to y",v);
#endif
    unit(A);
#ifdef NOISY
print("A set to 1",A);
#endif
    zero(B);
#ifdef NOISY
print("B set to 0",B);
#endif
    zero(C);
#ifdef NOISY
print("C set to 0",C);
#endif
    unit(D);
#ifdef NOISY
print("D set to 1",D);
#endif

#ifdef NOISY
printf("egcd/hhh\n");
#endif
    /* Until u==0: */
    do {

#ifdef NOISY
printf("egcd/iii   LUPTOP   do until u==1...\n");
print("u",u);
#endif
	/* While u is even: */
	while ( !((int)u->slot[0] & 1) ) {

#ifdef NOISY
printf("\negcd/jjj looping while u is even...\n");
print("u",u);
#endif
	    /* u=u/2: */
	    shift_roit_in_place( u, 1 );	
#ifdef NOISY
print("u >>= 1...",u);
#endif

#ifdef NOISY
printf("egcd/kkk are A and B both even?\n");
print("A",A);
print("B",B);
#endif
	    /* If both A and B are even: */
	    if ( !((int)A->slot[0] & 1)
	    &&   !((int)B->slot[0] & 1)
	    ){
#ifdef NOISY
printf("egcd/lll both A and B are even, so...\n");
#endif
		/* A=A/2, B=B/2: */
		shift_roit_in_place( A, 1 );	
#ifdef NOISY
print("A >>= 1",A);
#endif
		shift_roit_in_place( B, 1 );	
#ifdef NOISY
print("B >>= 1",B);
#endif

	    } else {
#ifdef NOISY
printf("egcd/mmm A and B not both even...\n");
print("A",A);
print("y",y);
#endif

		/* A=(A+y)/2 */
		add(t,A,y);
#ifdef NOISY
print("t=A+y",t);
#endif
		set(A,t);
#ifdef NOISY
print("A=t",A);
#endif
		shift_roit_in_place(A,1);	
#ifdef NOISY
print("A >>= 1",A);
#endif

		/* B=(B-x)/2 */
#ifdef NOISY
print("B",B);
print("x",x);
#endif
		sub(t,B,x);
#ifdef NOISY
print("t=B-x",t);
#endif
		set(B,t);
#ifdef NOISY
print("B=t",B);
#endif
		shift_roit_in_place(B,1);	
#ifdef NOISY
print("B >>= 1",B);
#endif
	    }
	}

#ifdef NOISY
printf("egcd/nnn while v is even...\n");
#endif
	/* While v is even: */
#ifdef NOISY
print("v",v);
#endif
	while ( !((int)v->slot[0] & 1) ) {

#ifdef NOISY
printf("egcd/ooo.aaa v is even...\n");
print("v",v);
printf("egcd/ooo.bbb\n");
#endif
	    /* v=v/2: */
	    shift_roit_in_place( v, 1 );	
#ifdef NOISY
printf("egcd/ooo.ccc\n");
print("v >>= 1",v);
#endif

#ifdef NOISY
printf("egcd/ppp are C and D both even?\n");
print("C",C);
print("D",D);
#endif
	    /* If both C and D are even: */
	    if ( !((int)C->slot[0] & 1)
	    &&   !((int)D->slot[0] & 1)
	    ){
#ifdef NOISY
printf("egcd/qqq C and D are both even...\n");
#endif
		/* C=C/2, D=D/2: */
		shift_roit_in_place( C, 1 );	
#ifdef NOISY
print("C >>= 1",C);
#endif
		shift_roit_in_place( D, 1 );	
#ifdef NOISY
print("D >>= 1",D);
#endif

	    } else {
#ifdef NOISY
printf("egcd/rrr C and D not both even...\n");
#endif

		/* C=(C+y)/2 */
#ifdef NOISY
print("C",C);
print("y",y);
#endif
		add(t,C,y);
#ifdef NOISY
print("t=C+y",t);
#endif
		set(C,t);
#ifdef NOISY
print("C=t",C);
#endif
		shift_roit_in_place(C,1);	
#ifdef NOISY
print("C >>= 1",C);
#endif

		/* D=(D-x)/2 */
#ifdef NOISY
print("D",D);
print("x",x);
#endif
		sub(t,D,x);
#ifdef NOISY
print("t=D-x",t);
#endif
		set(D,t);
#ifdef NOISY
print("D=t",D);
#endif
		shift_roit_in_place(D,1);	
#ifdef NOISY
print("D >>= 1",D);
#endif
	    }
	}

#ifdef NOISY
printf("egcd/sss: if u >= v\n");
print("u",u);
print("v",v);
#endif
	/* If u >= v: */
	if (order(u,v) != LESS) {

#ifdef NOISY
printf("egcd/ttt u >= v\n");
/* buggo -- what about if these go negative? */
print("u",u);
print("v",v);
#endif
	    /* u=u-v: */ sub(t,u,v); set(u,t);
#ifdef NOISY
print("u -= v",u);
print("A",A);
print("C",C);
#endif
	    /* A=A-C: */ sub(t,A,C); set(A,t);
#ifdef NOISY
print("A -= C",A);
print("B",B);
print("D",D);
#endif
	    /* B=B-D: */ sub(t,B,D); set(B,t);
#ifdef NOISY
print("B -= D",B);
#endif

	} else {

#ifdef NOISY
printf("egcd/uuu: u < v\n");
/* buggo -- what about if these go negative? */
print("v",v);
print("u",u);
#endif
	    /* v=v-u: */ sub(t,v,u); set(v,t);
#ifdef NOISY
print("t = v-u",t);
printf("t->length d=%" VM_D "\n",t->length);
printf("t->slot[0] x=%" VM_X "\n",t->slot[0]);
printf("t->slot[1] x=%" VM_X "\n",t->slot[1]);
print("v -= u",v);
print("v -= u",v);
printf("v->length d=%" VM_D "\n",v->length);
printf("v->slot[0] x=%" VM_X "\n",v->slot[0]);
printf("v->slot[1] x=%" VM_X "\n",v->slot[1]);
print("C",C);
print("A",A);
#endif
	    /* C=C-A: */ sub(t,C,A); set(C,t);
#ifdef NOISY
print("C -= A",C);
print("D",D);
print("B",B);
#endif
	    /* D=D-B: */ sub(t,D,B); set(D,t);
#ifdef NOISY
print("D -= B",D);
#endif
	}	

#ifdef NOISY
printf("egcd/sss testing for loop-end condition of u==0\n");
printf("u->length d=%" VM_D "\n",u->length);
print("u",u);
printf("v->length d=%" VM_D "\n",v->length);
print("v",v);
#endif
    } while ((int)u->length != 1   ||   u->slot[0]);
#ifdef NOISY
printf("egcd/vvv done main loop\n");
#endif

    mult( x, g,v );
#ifdef NOISY
printf("egcd/www\n");
#endif
}

/************************************************************************/
/*-    bnm_Egcd -- Euclid's extended Greatest Common Divisor		*/
/************************************************************************/

Vm_Obj
bnm_Egcd(
    Vm_Obj*oa,
    Vm_Obj*ob,
    Vm_Obj oxx,
    Vm_Obj oyy
){
    Vm_Obj ox   = bnm_Dup( oxx );	/* A copy that we can modify.	*/
    Vm_Obj oy   = bnm_Dup( oyy );	/* A copy that we can modify.	*/
    Vm_Unt lenx = BNM_P(ox)->length;
    Vm_Unt leny = BNM_P(oy)->length;
    Vm_Unt leng = (lenx > leny) ? lenx : leny;
    Vm_Obj og   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ot   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ou   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ov   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oA   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oB   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oC   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oD   = bnm_Alloc( leng, (Vm_Unt)0 );
    Bnm_P  x;
    Bnm_P  y;
    Bnm_P  g;
    Bnm_P  t;
    Bnm_P  u;
    Bnm_P  v;
    Bnm_P  A;
    Bnm_P  B;
    Bnm_P  C;
    Bnm_P  D;

    x  = (Bnm_P) vm_Loc( ox  );	vm_Register_Hard_Pointer( &ox , (void**)&x  );
    y  = (Bnm_P) vm_Loc( oy  );	vm_Register_Hard_Pointer( &oy , (void**)&y  );
    g  = (Bnm_P) vm_Loc( og  );	vm_Register_Hard_Pointer( &og , (void**)&g  );
    t  = (Bnm_P) vm_Loc( ot  );	vm_Register_Hard_Pointer( &ot , (void**)&t  );
    u  = (Bnm_P) vm_Loc( ou  );	vm_Register_Hard_Pointer( &ou , (void**)&u  );
    v  = (Bnm_P) vm_Loc( ov  );	vm_Register_Hard_Pointer( &ov , (void**)&v  );
    A  = (Bnm_P) vm_Loc( oA  );	vm_Register_Hard_Pointer( &oA , (void**)&A  );
    B  = (Bnm_P) vm_Loc( oB  );	vm_Register_Hard_Pointer( &oB , (void**)&B  );
    C  = (Bnm_P) vm_Loc( oC  );	vm_Register_Hard_Pointer( &oC , (void**)&C  );
    D  = (Bnm_P) vm_Loc( oD  );	vm_Register_Hard_Pointer( &oD , (void**)&D  );
    vm_Unregister_Hard_Pointer(                                 (void**)&D  );
    vm_Unregister_Hard_Pointer(                                 (void**)&C  );
    vm_Unregister_Hard_Pointer(                                 (void**)&B  );
    vm_Unregister_Hard_Pointer(                                 (void**)&A  );
    vm_Unregister_Hard_Pointer(                                 (void**)&v  );
    vm_Unregister_Hard_Pointer(                                 (void**)&u  );
    vm_Unregister_Hard_Pointer(                                 (void**)&t  );
    vm_Unregister_Hard_Pointer(                                 (void**)&g  );
    vm_Unregister_Hard_Pointer(                                 (void**)&y  );
    vm_Unregister_Hard_Pointer(                                 (void**)&x  );

    egcd( x,y, g, t, u,v, A,B,C,D );

    ox = maybeConvertToFixnum( ox, x );
    oC = maybeConvertToFixnum( oC, C );
    oD = maybeConvertToFixnum( oD, D );

    *oa = oC;
    *ob = oD;
    return ox;

    /* Could use static store for all the temps whenever they are below	*/
    /* some reasonable fixed size...					*/
}

/************************************************************************/
/*-    bnm_EgcdBI -- Euclid's extended Greatest Common Divisor		*/
/************************************************************************/

Vm_Obj
bnm_EgcdBI(
    Vm_Obj*oa,
    Vm_Obj*ob,
    Vm_Obj oxx,
    Vm_Obj oyy
){
    Vm_Obj ox   = bnm_Dup( oxx );	/* A copy that we can modify.	*/

    Vm_Unt lenx = BNM_P(ox)->length;

    Vm_Unt leng = lenx;
    Vm_Obj og   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ot   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ou   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ov   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oA   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oB   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oC   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oD   = bnm_Alloc( leng, (Vm_Unt)0 );
    Bnm_P  x;

    Bnm_P  g;
    Bnm_P  t;
    Bnm_P  u;
    Bnm_P  v;
    Bnm_P  A;
    Bnm_P  B;
    Bnm_P  C;
    Bnm_P  D;

    Vm_Int yyy = OBJ_TO_INT(oyy);
    struct Bnm_Header_Rec128 yy;
    yy.private        = FALSE;
    yy.is_a           = bnm_Type_Summary.builtin_class;
    yy.physicalLength = (Vm_Unt)128;
    yy.length         = (Vm_Unt)1;

    if (yyy < 0) {    yy.slot[0]    = -yyy; yy.sign = (Vm_Int)-1; }
    else {            yy.slot[0]    =  yyy; yy.sign = (Vm_Int) 1; }


    x  = (Bnm_P) vm_Loc( ox  );	vm_Register_Hard_Pointer( &ox , (void**)&x  );
    g  = (Bnm_P) vm_Loc( og  );	vm_Register_Hard_Pointer( &og , (void**)&g  );
    t  = (Bnm_P) vm_Loc( ot  );	vm_Register_Hard_Pointer( &ot , (void**)&t  );
    u  = (Bnm_P) vm_Loc( ou  );	vm_Register_Hard_Pointer( &ou , (void**)&u  );
    v  = (Bnm_P) vm_Loc( ov  );	vm_Register_Hard_Pointer( &ov , (void**)&v  );
    A  = (Bnm_P) vm_Loc( oA  );	vm_Register_Hard_Pointer( &oA , (void**)&A  );
    B  = (Bnm_P) vm_Loc( oB  );	vm_Register_Hard_Pointer( &oB , (void**)&B  );
    C  = (Bnm_P) vm_Loc( oC  );	vm_Register_Hard_Pointer( &oC , (void**)&C  );
    D  = (Bnm_P) vm_Loc( oD  );	vm_Register_Hard_Pointer( &oD , (void**)&D  );
    vm_Unregister_Hard_Pointer(                                 (void**)&D  );
    vm_Unregister_Hard_Pointer(                                 (void**)&C  );
    vm_Unregister_Hard_Pointer(                                 (void**)&B  );
    vm_Unregister_Hard_Pointer(                                 (void**)&A  );
    vm_Unregister_Hard_Pointer(                                 (void**)&v  );
    vm_Unregister_Hard_Pointer(                                 (void**)&u  );
    vm_Unregister_Hard_Pointer(                                 (void**)&t  );
    vm_Unregister_Hard_Pointer(                                 (void**)&g  );
    vm_Unregister_Hard_Pointer(                                 (void**)&x  );

    egcd( x,(Bnm_P)&yy, g, t, u,v, A,B,C,D );

    ox = maybeConvertToFixnum( ox, x );
    oC = maybeConvertToFixnum( oC, C );
    oD = maybeConvertToFixnum( oD, D );

    *oa = oC;
    *ob = oD;
    return ox;
}

/************************************************************************/
/*-    bnm_EgcdIB -- Euclid's extended Greatest Common Divisor		*/
/************************************************************************/

Vm_Obj
bnm_EgcdIB(
    Vm_Obj*oa,
    Vm_Obj*ob,
    Vm_Obj oxx,
    Vm_Obj oyy
){
    Vm_Obj ox   = bnm_Alloc( (Vm_Unt)1, (Vm_Unt)0 );
    Vm_Obj oy   = bnm_Dup( oyy );	/* A copy that we can modify.	*/

    Vm_Unt leny = BNM_P(oy)->length;

    Vm_Unt leng = leny;
    Vm_Obj og   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ot   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ou   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ov   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oA   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oB   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oC   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oD   = bnm_Alloc( leng, (Vm_Unt)0 );
    Bnm_P  x;
    Bnm_P  y;
    Bnm_P  g;
    Bnm_P  t;
    Bnm_P  u;
    Bnm_P  v;
    Bnm_P  A;
    Bnm_P  B;
    Bnm_P  C;
    Bnm_P  D;

    Vm_Int xxx = OBJ_TO_INT(oxx);

    x  = (Bnm_P) vm_Loc( ox  );	vm_Register_Hard_Pointer( &ox , (void**)&x  );
    y  = (Bnm_P) vm_Loc( oy  );	vm_Register_Hard_Pointer( &oy , (void**)&y  );
    g  = (Bnm_P) vm_Loc( og  );	vm_Register_Hard_Pointer( &og , (void**)&g  );
    t  = (Bnm_P) vm_Loc( ot  );	vm_Register_Hard_Pointer( &ot , (void**)&t  );
    u  = (Bnm_P) vm_Loc( ou  );	vm_Register_Hard_Pointer( &ou , (void**)&u  );
    v  = (Bnm_P) vm_Loc( ov  );	vm_Register_Hard_Pointer( &ov , (void**)&v  );
    A  = (Bnm_P) vm_Loc( oA  );	vm_Register_Hard_Pointer( &oA , (void**)&A  );
    B  = (Bnm_P) vm_Loc( oB  );	vm_Register_Hard_Pointer( &oB , (void**)&B  );
    C  = (Bnm_P) vm_Loc( oC  );	vm_Register_Hard_Pointer( &oC , (void**)&C  );
    D  = (Bnm_P) vm_Loc( oD  );	vm_Register_Hard_Pointer( &oD , (void**)&D  );
    vm_Unregister_Hard_Pointer(                                 (void**)&D  );
    vm_Unregister_Hard_Pointer(                                 (void**)&C  );
    vm_Unregister_Hard_Pointer(                                 (void**)&B  );
    vm_Unregister_Hard_Pointer(                                 (void**)&A  );
    vm_Unregister_Hard_Pointer(                                 (void**)&v  );
    vm_Unregister_Hard_Pointer(                                 (void**)&u  );
    vm_Unregister_Hard_Pointer(                                 (void**)&t  );
    vm_Unregister_Hard_Pointer(                                 (void**)&g  );
    vm_Unregister_Hard_Pointer(                                 (void**)&y  );
    vm_Unregister_Hard_Pointer(                                 (void**)&x  );

    if (xxx < 0) {    x->slot[0]    = -xxx; x->sign = (Vm_Int)-1; }
    else {            x->slot[0]    =  xxx; x->sign = (Vm_Int) 1; }

    egcd( x,y, g, t, u,v, A,B,C,D );

    ox = maybeConvertToFixnum( ox, x );
    oC = maybeConvertToFixnum( oC, C );
    oD = maybeConvertToFixnum( oD, D );

    *oa = oC;
    *ob = oD;
    return ox;
}

/************************************************************************/
/*-    bnm_EgcdII -- Euclid's extended Greatest Common Divisor		*/
/************************************************************************/

Vm_Obj
bnm_EgcdII(
    Vm_Obj*oa,
    Vm_Obj*ob,
    Vm_Obj oxx,
    Vm_Obj oyy
){
    Vm_Unt leng = (Vm_Unt)1;
    Vm_Obj ox   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj og   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ot   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ou   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj ov   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oA   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oB   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oC   = bnm_Alloc( leng, (Vm_Unt)0 );
    Vm_Obj oD   = bnm_Alloc( leng, (Vm_Unt)0 );
    Bnm_P  x;

    Bnm_P  g;
    Bnm_P  t;
    Bnm_P  u;
    Bnm_P  v;
    Bnm_P  A;
    Bnm_P  B;
    Bnm_P  C;
    Bnm_P  D;

    Vm_Int xxx = OBJ_TO_INT(oxx);
    Vm_Int yyy = OBJ_TO_INT(oyy);
    struct Bnm_Header_Rec128 yy;
    yy.private        = FALSE;
    yy.is_a           = bnm_Type_Summary.builtin_class;
    yy.physicalLength = (Vm_Unt)128;
    yy.length         = (Vm_Unt)1;

    if (yyy < 0) {    yy.slot[0]    = -yyy; yy.sign = (Vm_Int)-1; }
    else {            yy.slot[0]    =  yyy; yy.sign = (Vm_Int) 1; }


    x  = (Bnm_P) vm_Loc( ox  );	vm_Register_Hard_Pointer( &ox , (void**)&x  );
    g  = (Bnm_P) vm_Loc( og  );	vm_Register_Hard_Pointer( &og , (void**)&g  );
    t  = (Bnm_P) vm_Loc( ot  );	vm_Register_Hard_Pointer( &ot , (void**)&t  );
    u  = (Bnm_P) vm_Loc( ou  );	vm_Register_Hard_Pointer( &ou , (void**)&u  );
    v  = (Bnm_P) vm_Loc( ov  );	vm_Register_Hard_Pointer( &ov , (void**)&v  );
    A  = (Bnm_P) vm_Loc( oA  );	vm_Register_Hard_Pointer( &oA , (void**)&A  );
    B  = (Bnm_P) vm_Loc( oB  );	vm_Register_Hard_Pointer( &oB , (void**)&B  );
    C  = (Bnm_P) vm_Loc( oC  );	vm_Register_Hard_Pointer( &oC , (void**)&C  );
    D  = (Bnm_P) vm_Loc( oD  );	vm_Register_Hard_Pointer( &oD , (void**)&D  );
    vm_Unregister_Hard_Pointer(                                 (void**)&D  );
    vm_Unregister_Hard_Pointer(                                 (void**)&C  );
    vm_Unregister_Hard_Pointer(                                 (void**)&B  );
    vm_Unregister_Hard_Pointer(                                 (void**)&A  );
    vm_Unregister_Hard_Pointer(                                 (void**)&v  );
    vm_Unregister_Hard_Pointer(                                 (void**)&u  );
    vm_Unregister_Hard_Pointer(                                 (void**)&t  );
    vm_Unregister_Hard_Pointer(                                 (void**)&g  );
    vm_Unregister_Hard_Pointer(                                 (void**)&x  );

    if (xxx < 0) {    x->slot[0]    = -xxx; x->sign = (Vm_Int)-1; }
    else {            x->slot[0]    =  xxx; x->sign = (Vm_Int) 1; }

    egcd( x,(Bnm_P)&yy, g, t, u,v, A,B,C,D );

    ox = maybeConvertToFixnum( ox, x );
    oC = maybeConvertToFixnum( oC, C );
    oD = maybeConvertToFixnum( oD, D );

    *oa = oC;
    *ob = oD;
    return ox;
}

/************************************************************************/
/*-    bgcd -- Euclid's extended Greatest Common Divisor		*/
/************************************************************************/

static void
bgcd(
    Bnm_P x,	/* Input, and result.					*/
    Bnm_P y,	/* Input.						*/
    Bnm_P g,	/* Temp, big as x and y.				*/
    Bnm_P t	/* Temp, big as x and y.				*/
){
    /********************************************************************/
    /*  			Theory of Operation			*/
    /*									*/
    /* This fn follows algorithm 14.54 in Menezes' Handbook of Applied	*/
    /* Cryptography.  They don't really explain the algorithm, and I	*/
    /* won't venture to do so either.					*/
    /********************************************************************/

    /* Ignore the sign:							*/
    x->sign = (Vm_Unt)1;
    y->sign = (Vm_Unt)1;

    /* Set g = 1; */
    unit(g);
    
    /* If x==0 or y==0, return 1: */
    if ((int)x->length == 1  &&  !x->slot[0]) {   set(x,g);	return; }
    if ((int)y->length == 1  &&  !y->slot[0]) {   set(x,g);	return; }

    /* Ensure x > y: */
    {   int ord = magOrder(x,y);
	if (ord == LESS ) {	    bgcd( y, x, g, t );	    return;	}
	if (ord == EQUAL) {				    return;	}	
    }

    /* Drop (and tabulate) common powers of two: */
    while ( !((int)x->slot[0] & 1)	/* While both x and	*/
    &&	    !((int)y->slot[0] & 1)	/* and y are even	*/
    ) {
	shift_roit_in_place( x, 1 );	
	shift_roit_in_place( y, 1 );	
	shift_left_in_place( g, 1 );
    }
    /* Could change above to shift by more than one bit at a time.	*/
    /* Not likely to prove a frequent win in practice though, I'd guess.*/

    /* While x != 0: */
    while ((int)x->length > 1   ||   x->slot[0]) {
	
	/* Shift all least-significant zeros off x and y: */
	while (!(((int)x->slot[0]) & 1))   shift_roit_in_place( x, 1 );	
	while (!(((int)y->slot[0]) & 1))   shift_roit_in_place( y, 1 );	

	/* t = |x-y|/2: */
	sub( t, x, y );	
	t->sign = (Vm_Int) 1;
	shift_roit_in_place( t, 1 );	

	/* If x < y then y=t else x=t: */
	if (magOrder(x,y) == LESS)   set(y,t);
	else			     set(x,t);	
    }

    /* Return g*y: */
    mult( x, g,y );
}

/************************************************************************/
/*-    bnm_Bgcd -- binary Euclid's Greatest Common Divisor		*/
/************************************************************************/

Vm_Obj
bnm_Bgcd(
    Vm_Obj oxx,
    Vm_Obj oyy
){
    Vm_Obj ox   = bnm_Dup( oxx );	/* A copy that we can modify.	*/
    Vm_Obj oy   = bnm_Dup( oyy );	/* A copy that we can modify.	*/
    Vm_Unt lenx = BNM_P(ox)->length;
    Vm_Unt leny = BNM_P(oy)->length;
    Vm_Unt lent = (lenx > leny) ? lenx : leny;
    Vm_Obj ot   = bnm_Alloc( lent, (Vm_Unt)0 );
    Vm_Obj og   = bnm_Alloc( lent, (Vm_Unt)0 );
    Bnm_P  x;
    Bnm_P  y;
    Bnm_P  t;
    Bnm_P  g;
    vm_Loc4( (void**)
        &x, (void**)&y, (void**)&g, (void**)&t, 
        ox,         oy,         og,         ot
    );
    bgcd( x, y, g, t );	/* Result returns in x.	*/
    ox = maybeConvertToFixnum( ox, x );
    return ox;

    /********************************************************************/
    /* We could think about allocating a new bignum for ox before	*/
    /* returning it: Result is likely to be a lot smaller than the	*/
    /* inputs.  For now, I'm inclined to think this is likely to do	*/
    /* as much harm as good...						*/
    /********************************************************************/
}
    
/************************************************************************/
/*-    bnm_BgcdBI -- binary Euclid's Greatest Common Divisor		*/
/************************************************************************/

Vm_Obj
bnm_BgcdBI(
    Vm_Obj oxx,
    Vm_Obj oyy
){
    Vm_Obj ox   = bnm_Dup( oxx );	/* A copy that we can modify.	*/

    Vm_Int y    = OBJ_TO_INT(oyy);

    struct Bnm_Header_Rec128 yy;
    yy.private        = FALSE;
    yy.is_a           = bnm_Type_Summary.builtin_class;
    yy.physicalLength = (Vm_Unt)128;
    yy.length         = (Vm_Unt)1;

    if (y < 0) {    yy.slot[0]    = -y; yy.sign = (Vm_Int)-1; }
    else {          yy.slot[0]    =  y; yy.sign = (Vm_Int) 1; }

    {
	Vm_Unt lenx = BNM_P(ox)->length;
	Vm_Unt lent = lenx;
	Vm_Obj ot   = bnm_Alloc( lent, (Vm_Unt)0 );
	Vm_Obj og   = bnm_Alloc( lent, (Vm_Unt)0 );
	Bnm_P  x;
	Bnm_P  g;
	Bnm_P  t;
	vm_Loc3( (void**)
	    &x, (void**)&g, (void**)&t, 
	    ox,         og,         ot
	);
	bgcd( x, (Bnm_P)&yy, g, t );	/* Result returns in x.	*/
	ox = maybeConvertToFixnum( ox, x );
	return ox;
    }
    /********************************************************************/
    /* We could think about allocating a new bignum for ox before	*/
    /* returning it: Result is likely to be a lot smaller than the	*/
    /* inputs.  For now, I'm inclined to think this is likely to do	*/
    /* as much harm as good...						*/
    /********************************************************************/
}
    
/************************************************************************/
/*-    wordmult -- multiply two words to produce a two-word result.	*/
/************************************************************************/

#define VM_HALF_INT_BITS      (VM_INTBITS/2)
#define VM_HALF_INT_MASK     ((((Vm_Unt)1)<<VM_HALF_INT_BITS)-1)
#define CARRY_OUT             (((Vm_Unt)1)<<VM_HALF_INT_BITS)

/* Nasssty little trick to save two variables: */
#define midhi   alo
#define mid     alo
#define midlo   bhi

static void
wordmult(
    Vm_Unt*phi,		/* High half of result returned here.		*/
    Vm_Unt*plo,		/* Low  half of result returned here.		*/
    Vm_Unt  a,		/* First  input operand.			*/
    Vm_Unt  b		/* Second input operand.			*/
) {
    /********************************************************************/
    /*  			Theory of Operation			*/
    /*									*/
    /* Given a two-digit number Aa, and					*/
    /* another two-digit number Bb, the					*/
    /* straightforward way to compute their product is			*/
    /* the familiar grade-school expansion into a sum			*/	
    /* of four partial products AB, Ab, aB, ab:				*/
    /*									*/
    /*	       A   a							*/
    /*	     x B   b							*/
    /*	     -------							*/
    /*		  ab							*/
    /*		Ab							*/
    /*		aB							*/
    /*	  +   AB							*/
    /*	 -----------							*/
    /*       W X Y Z							*/
    /*									*/
    /* So one way to compute a 128-bit product of two 64-bit inputs	*/
    /* would be to use the above pattern on the 32-bit "digits".	*/
    /*									*/
    /* However, if additions are cheap and multiplications expensive	*/
    /* (many computers need 64 clock cycles to do a 64-bit integer	*/
    /* multiply, but only  one clock cycle  to do a 64-bit integer	*/
    /* addition), there is a simple but non-obvious algebraic trick	*/
    /* to speed the computation up by re-expressing it as:		*/
    /*									*/
    /*	       A   a							*/
    /*	     x B   b							*/
    /*	     -------							*/
    /*		  ab							*/
    /*	    (A-a)(b-B)							*/
    /*	  +   AB							*/
    /*	 -----------							*/
    /*       W X Y Z							*/
    /*									*/
    /* (with a little extra shifting not shown for simplicity).		*/
    /* This requires only three multiplies, at the cost of two		*/
    /* new subtractions.  (See Knuth, Art of Computer Programming	*/
    /* Vol II p 258, which attributes the idea to Karatsuba, 1962.)	*/
    /********************************************************************/

    /* Break both 'a' and 'b' into 32-bit halves: */
    Vm_Unt ahi = a >> VM_HALF_INT_BITS;    Vm_Unt alo = a & VM_HALF_INT_MASK;
    Vm_Unt bhi = b >> VM_HALF_INT_BITS;    Vm_Unt blo = b & VM_HALF_INT_MASK;

    /* Do the two 'end' multiplies: */
    Vm_Unt  hi = ahi * bhi;
    Vm_Unt  lo = alo * blo;

    /* Compute the two factors of the 'middle' multiply: */
    ahi    -= alo;	/* 'alo' last use, recycled as 'mid' & 'midhi'	*/
    blo    -= bhi;	/* 'bhi' last use, recycled as 'midlo'		*/

    /* Do the third, 'middle' multiply: */
    mid     = ahi * blo;



    /*******************************************************/
    /* That leaves 'just' the problem of adding the three  */
    /* 64-bit partial products correctly using only 64-bit */
    /* addition:                                           */ 
    /*******************************************************/

    {   Vm_Int carry   = mid ? -((ahi ^ blo) & CARRY_OUT) : 0;

        /* 'Middle' product currently has the form */
        /* -AB + aB + Ab + -ab:  We now cancel out */
        /* the outer two terms by adding in hi and */
        /* lo (which are respectively AB and ab):  */
	mid    += hi;    carry += ((Vm_Unt)(mid < hi)) << VM_HALF_INT_BITS;
	mid    += lo;    carry += ((Vm_Unt)(mid < lo)) << VM_HALF_INT_BITS;

	/* We now split 'mid' into two halves	   */
        /* midhi and midlo,  so we can merge them  */
	/* with (respectively) 'hi' and 'lo':	   */	
	midlo   = mid << VM_HALF_INT_BITS;
	midhi   = mid >> VM_HALF_INT_BITS;	/* 'mid' reused as 'midhi'*/	

	/* Merge 'midlo' into 'lo' output result:  */
	lo     += midlo;
	carry  += (Vm_Unt)(lo < midlo);

	/* Merge 'midhi' into 'hi' output result:  */
	hi     += carry + midhi;
    }


    /* Return completed product in halves: */
    *phi    = hi;
    *plo    = lo;


    /********************************************************************/
    /* Possible improvements:						*/
    /*									*/
    /* Write assembly versions for x86 &tc, where we get hardware	*/
    /* support for carry-generation &tc.				*/
    /********************************************************************/
}


/************************************************************************/
/*-    partialProduct -- one partial product in full multiplication	*/
/************************************************************************/

static void
partialProduct(
    Bnm_P  c,
    Bnm_P  a,
    Vm_Unt w,
    int    offset
) {
    Vm_Unt carry = (Vm_Unt)0;
    int    lena  = (int) a->length;
    #if MUQ_IS_PARANOID
    int    lenc  = (int) c->physicalLength;
    #endif

    /* Multiply word w from 'b' all the way through 'a',  */
    /* accumulating the resulting partial product at the  */
    /* appropriate offset in 'c':                         */
    Vm_Unt hi, lo, ci;
    int  i;
    for (i = 0;   i < lena;   i++) {

	wordmult( &hi, &lo, w, a->slot[i] );

	lo += carry;
	hi += (Vm_Unt)(lo < carry);

	c->slot[i+offset] = ci = c->slot[i+offset] + lo;
	carry = hi + (Vm_Unt)(ci < lo);
    }
    if ((lena+offset) > (int)c->length)   c->length = (Vm_Unt)(lena+offset);

    /* Propagate any carry as needed: */
    for (i = lena + offset;   carry;   ++i) {

	#if MUQ_IS_PARANOID
	if (i >= lenc) {
	    MUQ_FATAL("bnm:partialProduct: internal err");
	}
	#endif
        if (i+1 > (int)c->length)   c->length = (Vm_Unt)(i+1);

	c->slot[i] = ci = c->slot[i] + carry;
	carry      = (Vm_Unt)(ci < carry);
    }

    normalize(c);
}

/************************************************************************/
/*-    mult -- static multiply of two bignums				*/
/************************************************************************/

static void
mult(
    Bnm_P c,	/* Output: state irrelevant, size relevant.		*/
    Bnm_P a,	/* Input.						*/
    Bnm_P b	/* Input.						*/
) {
    zero(c);

    /* Compute sign of result: */
    {   int     sa     = (int) a->sign;
	int     sb     = (int) b->sign;
	int     signab = (sa << 1) +sb;
	switch (signab) {
	case POS_POS: 
	case NEG_NEG: c->sign =  1;		break;
	case POS_NEG:
	case NEG_POS: c->sign = -1;		break;
	}
    }

    {   int  lenb = (int) b->length;

	/* Over all words in 'b': */
	int  i;
	for (i = 0;   i < lenb;   ++i) {

	    /* Form partial product consisting of word 	*/
	    /* b->slot[i] times complete value of 'a',	*/
	    /* and add this partial product into 'c' at	*/
	    /* the appropriate offset:			*/
	    partialProduct( c, a, b->slot[i], i );
	}
    }
}

/************************************************************************/
/*-    bnm_Mult -- multiply two bignums					*/
/************************************************************************/

Vm_Obj
bnm_Mult(
    Vm_Obj oa,
    Vm_Obj ob,
    Bnm_P  b
){
    /********************************************************************/
    /* This function just implements the generic O(N^2) longhand	*/
    /* multiplication algorithm that Ms Grundy taught you in grade	*/
    /* school, except that it operates on 64-bit 'digits' instead	*/
    /* of base-10 digits:						*/
    /********************************************************************/

    /* Zero times most anything is zero: */
    Bnm_P  a;
    vm_Loc2( (void**)&a, (void**)&b, oa, ob );
    {   Vm_Unt lena = a->length;
	Vm_Unt lenb = b->length;
	if (lena == (Vm_Unt)1  && !a->slot[0])   return OBJ_FROM_INT(0);
        if (lenb == (Vm_Unt)1  && !b->slot[0])   return OBJ_FROM_INT(0);

	{   /* Allocate result object: */
	    Vm_Obj oc    = bnm_Alloc( lena+lenb, (Vm_Unt)0 );
	    Bnm_P  c;
	    vm_Loc3( (void**)&a, (void**)&b, (void**)&c, oa, ob, oc );
	    
	    mult( c, a, b );

	    oc = maybeConvertToFixnum( oc, c );

	    return oc;
	}
    }

    /********************************************************************/
    /* Possible improvements:						*/
    /*									*/
    /* o Write a specialized routine for squaring.			*/
    /*									*/
    /* o Use Karatsuba recursively all the way down instead of just	*/
    /*   in wordmult.  This buys something less than a 25% speedup	*/
    /*   for each recursion level: For largest currently supported	*/
    /*   numbers, that might be a 70% or so speedup.			*/
    /*									*/
    /* o Review Knuth. E.g. FFT multiplication sounds like fun, but it	*/
    /*   apparently doesn't become a win until very large numbers.	*/
    /*									*/
    /* o Poke around for post-Knuth ideas.				*/
    /********************************************************************/
}
    
/************************************************************************/
/*-    bnm_MultBI -- multiply bignum and fixnum				*/
/************************************************************************/

Vm_Obj
bnm_MultBI(
    Vm_Obj oa,
    Vm_Obj ob
){
    Vm_Int b    = OBJ_TO_INT(ob);

    struct Bnm_Header_Rec128 xb;
    xb.private        = FALSE;
    xb.is_a           = bnm_Type_Summary.builtin_class;
    xb.physicalLength = (Vm_Unt)128;
    xb.length         = (Vm_Unt)1;

    if (b < 0) {    xb.slot[0]    = -b; xb.sign = (Vm_Int)-1; }
    else {          xb.slot[0]    =  b; xb.sign = (Vm_Int) 1; }

    return bnm_Mult( oa, OBJ_FROM_INT(0), (Bnm_P)&xb );
}
    
/************************************************************************/
/*-    bnm_MultII -- multiply two fixnums				*/
/************************************************************************/

Vm_Obj
bnm_MultII(
    Vm_Int a,
    Vm_Int b
){
    /****************************************/
    /* This routine is normally called only */
    /* if the fixnum subtraction overflows  */ 
    /* fixnum precision, requiring a bignum */
    /* to hold the result.                  */
    /****************************************/

    Vm_Obj oc   = bnm_Alloc( (Vm_Unt)2, (Vm_Unt)0 );

    struct Bnm_Header_Rec128 xa;
    struct Bnm_Header_Rec128 xb;

    xa.private        = FALSE;
    xb.private        = FALSE;

    xa.is_a           = bnm_Type_Summary.builtin_class;
    xb.is_a           = bnm_Type_Summary.builtin_class;

    xa.physicalLength = (Vm_Unt)128;
    xb.physicalLength = (Vm_Unt)128;

    xa.length         = (Vm_Unt)1;
    xb.length         = (Vm_Unt)1;

    if (a < 0) {    xa.slot[0]    = -a; xa.sign = (Vm_Int)-1; }
    else {          xa.slot[0]    =  a; xa.sign = (Vm_Int) 1; }

    if (b < 0) {    xb.slot[0]    = -b; xb.sign = (Vm_Int)-1; }
    else {          xb.slot[0]    =  b; xb.sign = (Vm_Int) 1; }

    {   Bnm_P  c = vm_Loc(oc);
	mult( c, (Bnm_P)&xa, (Bnm_P)&xb );
        vm_Dirty(oc);
        oc = maybeConvertToFixnum( oc, c );
    }

    return oc;
}
    
/************************************************************************/
/*-    bnm_Pow -- raise a bignum to a power				*/
/************************************************************************/

Vm_Obj
bnm_Pow(
    Vm_Obj oa,		/* base.					*/
    Vm_Unt e,		/* power.					*/
    Bnm_P  a		/* If !oa, use a instead.			*/
){
    Vm_Unt abits;	/* Significant bits in input operand 'oa'	*/
    Vm_Unt cbits;	/* Estimated   bits in result bignum 'oc'	*/
    Vm_Unt cwords;	/* Estimated  words in result bignum 'oc'	*/
    Vm_Int csign;

    if (oa)   a = BNM_P(oa);

    /* Compute sign for result -- negative only */
    /* if input is negative and exponent odd:   */
    csign   = (a->sign == (Vm_Int)-1 && (e&1) ? (Vm_Int)-1 : (Vm_Int)1);

    abits   = bits(  a);

    cbits  = e * abits;
    cwords = (cbits + (VM_INTBITS-1)) >> VM_LOG2_INTBITS;

    /* Avoid trying to compute a trillion-digit answer or such: */
    if (e     > (MAX_BIGNUM*VM_INTBITS)
    ||  cbits > (MAX_BIGNUM*VM_INTBITS)
    ){
	MUQ_WARN("bnm_Pow: exponent too large for current implementation");
    }

    
    {   /* Allocate the result bignum and a pair of temps: */
	Vm_Obj oc = bnm_Alloc( cwords, (Vm_Unt)0 );	/* Result bignum.	*/
	Vm_Obj ot = bnm_Dup(   oc		 );	/* First temp bignum.	*/
	Vm_Obj ou = bnm_Dup(   oc		 );	/* Second temp bignum.	*/
	Bnm_P  c;
	Bnm_P  t;
	Bnm_P  u;
	vm_Loc4(
	    (void**)&a,
	    (void**)&c,
	    (void**)&t,
	    (void**)&u,
	    oa, oc, ot, ou
	);

	/************************************************************************/
	/* The naive binary square and multiply method used here is based	*/
	/* on the observation that if we view the exponent as a binary number,	*/
	/* then (say)								*/
	/*									*/
	/*	100011	    1	 10    100000	  1    2    32			*/
	/*     a        == a  * a   * a       == a  * a  * a			*/	
	/*									*/
	/* and in general we can decompose any such result into a product of	*/
	/* powers of 'a' obtained from successive squarings.  (This is very 	*/
	/* much like the naive binary multiplication algorithm which works	*/
	/* by adding in binary shifts of 'b' for each 1 bit in 'a', except	*/
	/* that we're using squares and products in place of shifts and adds.)	*/
	/************************************************************************/

	/* Initialize power-of-a temp to 'a': */
	set( t, a );

	/* Initialize output to one: */
	unit(c);

	/* For each bit in the exponent: */
	for (;;) {

	    /* If we've reached a '1' bit in the exponent, */
	    /* multiply in the current power of 'a':	   */
	    if (e & 1) {
	        /* c *= t: */
		mult( u, c, t );
		set(  c, u    );
	    }

	    if (!(e >>= 1))   break;

	    /* Generate next power of 'a' by squaring current power: */
	    mult( u, t, t );
	    set(  t, u    );
	}

	/* Set sign of result: */
	c->sign = csign;

	oc = maybeConvertToFixnum( oc, c );

	return oc;
    }

    /********************************************************************/
    /* Possible improvements:						*/
    /*									*/
    /* o It is possible to optimize the "addition chain" so as to	*/
    /*   do fewer operations:  Be nice to dig up the state of the	*/
    /*   art on this at some point and code up something practical.	*/
    /*	 (As usual, finding the optimal chain is intractable.)		*/
    /*									*/
    /* o http://www.eleceng.adelaide.edu.au/Groups/DIGITAL/CRYPT/reports.html */ 
    /*	 has a postscript review of algorithms for exponentiating long  */
    /*   integers.  E.g., Brickell has a trick for guaranteeing that at */
    /*   most half the exponent bits are 1 by re-expressing it as a     */
    /*   higher power minus the complement if it starts out 1-rich:	*/
    /*   this can reduce the number of accumulation multiplies needed.	*/	
    /*									*/
    /* o There are also hacks to process the exponents in groups of	*/
    /*   bits rather than single bits -- i.e., in a higher radix.	*/
    /*   The general conclusion of the above paper appears to be that	*/
    /*   there are no stunning wins.  (Oddly, they seem to		*/
    /*   make no mention off Montgomery exponentiation, however...)	*/
    /*									*/
    /********************************************************************/
}
    
/************************************************************************/
/*-    bnm_PowI -- raise a fixnum to a power				*/
/************************************************************************/

Vm_Obj
bnm_PowI(
    Vm_Obj oa,
    Vm_Unt e
){
    Vm_Int a    = OBJ_TO_INT(oa);
    struct Bnm_Header_Rec128 xa;
    xa.private        = FALSE;
    xa.is_a           = bnm_Type_Summary.builtin_class;
    xa.physicalLength = (Vm_Unt)128;
    xa.length         = (Vm_Unt)1;

    if (a < 0) {    xa.slot[0]    = -a; xa.sign = (Vm_Int)-1; }
    else {          xa.slot[0]    =  a; xa.sign = (Vm_Int) 1; }

    return bnm_Pow( OBJ_FROM_INT(0), e, (Bnm_P)&xa );
}
    
/************************************************************************/
/*-    bnm_Smallest_Positive_Bignum --					*/
/************************************************************************/

Vm_Obj
bnm_Smallest_Positive_Bignum(
    void
){
    /* The most negative possible fixnum in two's complement notation	*/
    /* has no positive fixnum equivalent -- to negate it, we must	*/
    /* create a bignum.  This function creates the required bignum;	*/
    /* It is invoked by the 'neg' code in jobbuild.t, integer case.	*/
    return bnm_Alloc( (Vm_Unt)0, (Vm_Unt)-BNM_THE_NEGATIVE_FIXNUM_WITH_NO_MATCHING_POSITIVE_FIXNUM );

    /* Possible improvement: We could allocate a permanent instance of  */
    /* this number.  But I don't expect this to happen often enough	*/
    /* for performance to be an issue.					*/
}
    
/************************************************************************/
/*-    bnm_Neg -- negate a bignum					*/
/************************************************************************/

Vm_Obj
bnm_Neg(
    Vm_Obj oa
){
    Vm_Obj oc = bnm_Dup( oa );
    BNM_P(oc)->sign = -BNM_P(oc)->sign;  vm_Dirty(oc);
    return oc;
}
    
/************************************************************************/
/*-    montgomeryMult -- static Montgomery modular 'multiply'		*/
/************************************************************************/

static void
montgomeryMult( /*               -1      */
    Bnm_P  A,	/* Result, == xyR  mod m */
    Bnm_P  x,	/* Input operand < m	 */
    Bnm_P  y,	/* Input operand < m	 */
    Bnm_P  m,	/* Input operand	 */
    Bnm_P  R,	/* Input operand	 */
    Vm_Unt m1,	/* Input operand	 */
    Bnm_P t,	/* Temp			 */
    Bnm_P g,	/* Temp			 */
    Bnm_P u	/* Temp			 */
) {
    int lenx = (int)x->length;
/*  int leny = (int)y->length; */
    int lenm = (int)m->length;
    /********************************************************************/
    /*  			Theory of Operation			*/
    /*									*/
    /* Multiplication of a*b mod m using "Montgomery Multiplication".	*/
    /* This fn follows algorithm 14.36 in Menezes' Handbook of Applied	*/
    /* Cryptography.  Note that Montgomery Multiplication isn't		*/
    /* suggested for actual use by itself for lone multiplications,	*/
    /* since it is slower than the naive algorithm -- it is primarily	*/
    /* significant as a building block for Montgomery Exponentiation,	*/
    /* which is a big win over naive modular exponentiation.		*/
    /********************************************************************/

    zero(A);
#ifdef NOISY
printf("montgomeryMult/top m1 x=%" VM_X "\n",m1);
print("x",x);
print("y",y);
print("m",m);
print("R",R);
print("A",A);
printf("Above main loop from 0 < lenm d=%d\n",lenm);
#endif

    {   int  i;
        for (i = 0;   i < lenm;   ++i) {

	    /******************************/
	    /*                   '	  */
	    /* u  = (a  + x y )*m  mod b: */
	    /*  i     0    i 0		  */
	    /******************************/
	    Vm_Unt xi = (i < lenx) ? x->slot[i] : (Vm_Unt)0;
	    Vm_Unt ui = (A->slot[0] + xi*y->slot[0]) * m1;
#ifdef NOISY
printf("montgomeryMult/luptop i d=%d\n",i);
printf("montgomeryMult/lup xi x=%" VM_X "\n",xi);
printf("montgomeryMult/lup ui x=%" VM_X "\n",ui);
#endif


	    /******************************/
	    /* A <- (A + x y + u m) / b:  */
	    /*            i     i         */
	    /******************************/

	    zero(t);    t->slot[0] = xi;    mult( u, t,y );
	    zero(t);    t->slot[0] = ui;    mult( g, t,m );
#ifdef NOISY
print("y",y);
print("u = xi * y",u);
print("m",m);
print("g = ui * m",g);
#endif
	    add(t, u,g );	    
#ifdef NOISY
print("t=u+g",t);
#endif

	    add(u, A,t );
#ifdef NOISY
print("u=A+t",u);
#endif
	    set(A,u);
#ifdef NOISY
print("A=u",A);
#endif

	    shift_roit_in_place( A, VM_INTBITS );
#ifdef NOISY
print("A >>= INTBITS",A);
#endif
	}
#ifdef NOISY
printf("montgomeryMult below main loop i d=%d\n",i);
print("A",A);
print("m",m);
#endif
    }

    /* If A >= m then A <- A-M: */
    if (magOrder(A,m) != LESS) {    
#ifdef NOISY
printf("subtracting m from A...\n");
#endif
	sub(t,A,m);
	set(A,t);
    }
#ifdef HYPERPARANOID
/* Verify final result by other means: */
{
  struct Bnm_Header_Rec128 _x;
  struct Bnm_Header_Rec128 _y;
  struct Bnm_Header_Rec128 _g;
  struct Bnm_Header_Rec128 _t;
  struct Bnm_Header_Rec128 _u;
  struct Bnm_Header_Rec128 _v;
  struct Bnm_Header_Rec128 _A;
  struct Bnm_Header_Rec128 _B;
  struct Bnm_Header_Rec128 _C;
  struct Bnm_Header_Rec128 _D;
  struct Bnm_Header_Rec128 _R;

  _x.private         = FALSE;
  _y.private         = FALSE;
  _g.private         = FALSE;
  _t.private         = FALSE;
  _u.private         = FALSE;
  _v.private         = FALSE;
  _A.private         = FALSE;
  _B.private         = FALSE;
  _C.private         = FALSE;
  _D.private         = FALSE;
  _R.private         = FALSE;

  _x.is_a            = bnm_Type_Summary.builtin_class;
  _y.is_a            = bnm_Type_Summary.builtin_class;
  _g.is_a            = bnm_Type_Summary.builtin_class;
  _t.is_a            = bnm_Type_Summary.builtin_class;
  _u.is_a            = bnm_Type_Summary.builtin_class;
  _v.is_a            = bnm_Type_Summary.builtin_class;
  _A.is_a            = bnm_Type_Summary.builtin_class;
  _B.is_a            = bnm_Type_Summary.builtin_class;
  _C.is_a            = bnm_Type_Summary.builtin_class;
  _D.is_a            = bnm_Type_Summary.builtin_class;
  _R.is_a            = bnm_Type_Summary.builtin_class;

  _x.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  _y.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  _g.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  _t.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  _u.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  _v.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  _A.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  _B.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  _C.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  _D.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
  _R.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;
set( (Bnm_P)&_R, R);
  /*                 -1
  /* First, compute R  mod m: */
  set( (Bnm_P)&_x, m);
  set( (Bnm_P)&_y, (Bnm_P)&_R);
zero((Bnm_P)&_g);
zero((Bnm_P)&_t);
zero((Bnm_P)&_u);
zero((Bnm_P)&_v);
zero((Bnm_P)&_A);
zero((Bnm_P)&_B);
zero((Bnm_P)&_C);
zero((Bnm_P)&_D);
#ifdef NOISY
print("_x (pre egcd) ",(Bnm_P)&_x);
print("_y (pre egcd) ",(Bnm_P)&_y);
#endif
  egcd(
      (Bnm_P)&_x,	/* Input, and gcd is returned here.			*/
      (Bnm_P)&_y,	/* Input, DESTROYED DURING COMPUTATION.			*/
      
      (Bnm_P)&_g,	/* Temp.						*/
      (Bnm_P)&_t,	/* Scratch -- could drop if we had 2-arg add & sub.	*/
      
      (Bnm_P)&_u,	/* Temp.						*/
      (Bnm_P)&_v,	/* Temp.						*/
      
      (Bnm_P)&_A,	/* Temp.						*/
      (Bnm_P)&_B,	/* Temp.						*/
      (Bnm_P)&_C,	/* Temp, and extended return value.			*/
      (Bnm_P)&_D	/* Temp, and extended return value.			*/
  );
#ifdef NOISY
print("_x (post egcd) ",(Bnm_P)&_x);
print("_C (post egcd) ",(Bnm_P)&_C);
print("_D (post egcd) ",(Bnm_P)&_D);
#endif
mult( (Bnm_P)&_u, m, (Bnm_P)&_C );
mult( (Bnm_P)&_v, (Bnm_P)&_R, (Bnm_P)&_D );
#ifdef NOISY
print("_u =  m * _C ",(Bnm_P)&_u);
print("_v = _R * _D ",(Bnm_P)&_v);
#endif
add( (Bnm_P)&_t, (Bnm_P)&_u, (Bnm_P)&_v );
#ifdef NOISY
print("_t = _u + _v ",(Bnm_P)&_t);
#endif


  if (_D.sign == (Vm_Int)-1) {
zero((Bnm_P)&_t);
#ifdef NOISY
printf("_D is negative...\n");
print("m",m);
print("_D",(Bnm_P)&_D);
#endif
    add( (Bnm_P)&_t, m, (Bnm_P)&_D );
#ifdef NOISY
print("_t = m + _D ",(Bnm_P)&_t);
#endif
    set( (Bnm_P)&_D, (Bnm_P)&_t );
#ifdef NOISY
print("_D = _t",(Bnm_P)&_D);
#endif
  }
  /* Check that _D*(Bnm_P)&_R == 1 mod m */
zero((Bnm_P)&_t);
  mult( (Bnm_P)&_t, (Bnm_P)&_D, (Bnm_P)&_R );
zero((Bnm_P)&_g);
zero((Bnm_P)&_u);
zero((Bnm_P)&_v);
  divmod(
      (Bnm_P)&_g, /* protoQuotient  */
      (Bnm_P)&_u, /* protoRemainder */
      (Bnm_P)&_v, /* shiftedDivisor */
      (Bnm_P)&_t, /* dividend       */
      m           /* divisor        */
  );
  if (_u.length != (Vm_Unt)1 || _u.slot[0] != (Vm_Unt)1) {
printf(" HYPERPARANOID INVERSE FAILED...?!-----------\n");
print( "_R", (Bnm_P)&_R);
print("_D",(Bnm_P)&_D);
print("_t = _R*_D",(Bnm_P)&_t);
print("m",m);
print("_u = _t mod m",(Bnm_P)&_u);
printf(" --------------------------------------------\n");
  } else {
printf(" HYPERPARANOID INVERSE OK\n");
#ifdef NOISY
print("_u",(Bnm_P)&_u);
#endif
  }
  /*                        -1  */
  /* Now, multiply x * y * R    */
  mult( (Bnm_P)&_t, (Bnm_P)&_D, x );
#ifdef NOISY
print("_t = _D * x",(Bnm_P)&_t);
#endif
  mult( (Bnm_P)&_u, (Bnm_P)&_t, y );
#ifdef NOISY
print("_u = _t * y",(Bnm_P)&_u);
#endif
  /* Take it all mod m: */
#ifdef NOISY
print("m",m);
#endif
  divmod(
      (Bnm_P)&_g, /* protoQuotient  */
      (Bnm_P)&_A, /* protoRemainder */
      (Bnm_P)&_t, /* shiftedDivisor */
      (Bnm_P)&_u, /* dividend       */
      m           /* divisor        */
  );
#ifdef NOISY
printf("divmod done...\n");
print("_A = _u mod m",(Bnm_P)&_A);
#endif
  /* Result should equal A: */ 
  if (order((Bnm_P)&_A,A) != EQUAL) {
printf(" HYPERPARANOID CHECK FAILED...?!-----------\n");
print( "x", x);
print( "y", y);
print( "R", R);
print( "_D", (Bnm_P)&_D);
print( "_u", (Bnm_P)&_u);
print( "m", m);
print( "_A", (Bnm_P)&_A);
print("A",A);
printf(" ------------------------------------------\n");
/* Try substituting conventional value for montgomery routine's value: */
set(A,(Bnm_P)&_A);
} else {
printf(" -> HYPERPARANOID CHECK PASSED <- \n");
  }
}
#endif
}


/************************************************************************/
/*-    bnm_Multmod -- 'Montgomery Multiply' two bignums mod a bignum	*/
/************************************************************************/

#ifdef CURRENTLY_UNUSED
Vm_Obj
bnm_Multmod(
    Vm_Obj oxx,
    Vm_Obj oyy,
    Vm_Obj om
){

    /* Duplicate xx and yy so we can fiddle with them.  */
    /* This may not be strictly necessary.		*/
    Vm_Obj ox   = bnm_Dup( oxx );
    Vm_Obj oy   = bnm_Dup( oyy );

    /* Allocate a temporary: */
/*  Vm_Unt lenx = BNM_P(ox)->length; */
/*  Vm_Unt leny = BNM_P(oy)->length; */
    Vm_Unt lent = BNM_P(om)->length;

    Vm_Obj og   = bnm_Alloc( lent  , (Vm_Unt)0 );
    Vm_Obj ot   = bnm_Alloc( lent  , (Vm_Unt)0 );

    Vm_Obj ou   = bnm_Alloc( lent  , (Vm_Unt)0 );
    Vm_Obj ov   = bnm_Alloc( lent  , (Vm_Unt)0 );

    Vm_Obj oA   = bnm_Alloc( lent  , (Vm_Unt)0 );
    Vm_Obj oB   = bnm_Alloc( lent  , (Vm_Unt)0 );
    Vm_Obj oC   = bnm_Alloc( lent  , (Vm_Unt)0 );
    Vm_Obj oD   = bnm_Alloc( lent  , (Vm_Unt)0 );

    Vm_Obj oR   = bnm_Alloc( lent+1, (Vm_Unt)0 );
    Vm_Obj oM   = bnm_Alloc( lent  , (Vm_Unt)0 );

    Vm_Unt m1;

    /* Get static pointers to them all: */
    Bnm_P  x;
    Bnm_P  y;
    Bnm_P  g;
    Bnm_P  m;
    Bnm_P  t;
    Bnm_P  u;
    Bnm_P  v;
    Bnm_P  A;
    Bnm_P  B;
    Bnm_P  C;
    Bnm_P  D;
    Bnm_P  M;
    Bnm_P  R;

    x  = (Bnm_P) vm_Loc( ox  );	vm_Register_Hard_Pointer( &ox , (void**)&x  );
    y  = (Bnm_P) vm_Loc( oy  );	vm_Register_Hard_Pointer( &oy , (void**)&y  );
    g  = (Bnm_P) vm_Loc( og  );	vm_Register_Hard_Pointer( &og , (void**)&g  );
    m  = (Bnm_P) vm_Loc( om  );	vm_Register_Hard_Pointer( &og , (void**)&m  );
    t  = (Bnm_P) vm_Loc( ot  );	vm_Register_Hard_Pointer( &ot , (void**)&t  );
    u  = (Bnm_P) vm_Loc( ou  );	vm_Register_Hard_Pointer( &ou , (void**)&u  );
    v  = (Bnm_P) vm_Loc( ov  );	vm_Register_Hard_Pointer( &ov , (void**)&v  );
    A  = (Bnm_P) vm_Loc( oA  );	vm_Register_Hard_Pointer( &oA , (void**)&A  );
    B  = (Bnm_P) vm_Loc( oB  );	vm_Register_Hard_Pointer( &oB , (void**)&B  );
    C  = (Bnm_P) vm_Loc( oC  );	vm_Register_Hard_Pointer( &oC , (void**)&C  );
    D  = (Bnm_P) vm_Loc( oD  );	vm_Register_Hard_Pointer( &oD , (void**)&D  );
    M  = (Bnm_P) vm_Loc( oM  );	vm_Register_Hard_Pointer( &oM , (void**)&M  );
    R  = (Bnm_P) vm_Loc( oR  );	vm_Register_Hard_Pointer( &oR , (void**)&R  );
    vm_Unregister_Hard_Pointer(                                 (void**)&R  );
    vm_Unregister_Hard_Pointer(                                 (void**)&M  );
    vm_Unregister_Hard_Pointer(                                 (void**)&D  );
    vm_Unregister_Hard_Pointer(                                 (void**)&C  );
    vm_Unregister_Hard_Pointer(                                 (void**)&B  );
    vm_Unregister_Hard_Pointer(                                 (void**)&A  );
    vm_Unregister_Hard_Pointer(                                 (void**)&v  );
    vm_Unregister_Hard_Pointer(                                 (void**)&u  );
    vm_Unregister_Hard_Pointer(                                 (void**)&t  );
    vm_Unregister_Hard_Pointer(                                 (void**)&m  );
    vm_Unregister_Hard_Pointer(                                 (void**)&g  );
    vm_Unregister_Hard_Pointer(                                 (void**)&y  );
    vm_Unregister_Hard_Pointer(                                 (void**)&x  );

    /* We need 0 <= x,y < m as an initial condition, with m odd: */
    if ((int)x->sign != 1) MUQ_WARN("bnm_Multmod: x cannot be negative.");
    if ((int)y->sign != 1) MUQ_WARN("bnm_Multmod: y cannot be negative.");
    if ((int)m->sign != 1) MUQ_WARN("bnm_Multmod: m cannot be negative.");
    if (m->length == 1 && m->slot[0] == (Vm_Unt)0) {
	MUQ_WARN("bnm_Multmod: m may not be zero");
    }
    if (!((int)m->slot[0] & 1)) {
	MUQ_WARN("bnm_Multmod: m must be odd");
    }
    if (magOrder(x,m) != LESS) {
        /* Do x = x mod m: */
	divmod(
	    A,	/* Quotient, discarded.		*/
	    B,  /* Remainder, our quarry	*/
	    C,  /* ShiftedDivisor, a temp.	*/
	    x,	/* dividend, an input		*/
	    m	/* divisor, other input.	*/
	);
        set(x,B);		
    }
    if (magOrder(y,m) != LESS) {
        /* Do y = y mod m: */
	divmod(
	    A,	/* Quotient, discarded.		*/
	    B,  /* Remainder, our quarry	*/
	    C,  /* ShiftedDivisor, a temp.	*/
	    y,	/* dividend, an input		*/
	    m	/* divisor, other input.	*/
	);
        set(y,B);		
    }


    /*************************/
    /*             -1        */
    /* Set m1 to -m   mod b: */
    /*************************/

    /* Set R to b, base of one word:   */
    R->length = (Vm_Unt)2;
    R->slot[1]= (Vm_Unt)1;
    R->slot[0]= (Vm_Unt)0;

    /* Set M to m:   */
    set(M,m);

    /*                -1 		*/
    /* egcd computes m   mod b for us:	*/
    egcd(
	M,	/* Input, and gcd of 1 is returned here.		*/
	R,	/* Input, DESTROYED DURING COMPUTATION			*/
	
	g,	/* Temp.						*/
	t,	/* Scratch -- could drop if we had 2-arg add & sub.	*/
	
	u,	/* Temp.						*/
	v,	/* Temp.						*/
	
	A,	/* Temp.						*/
	B,	/* Temp.						*/
	C,	/* Temp, and desired   return value.			*/
	D	/* Temp, and discarded return value.			*/
    );
    m1 = -C->slot[0];

    /* Set R to our power-of-two radix larger than m: */
    {   int  i;
	for (i = 0;  i < lent;   ++i)   R->slot[i] = (Vm_Unt)0;
	R->slot[lent] = (Vm_Unt)1;
	R->length     = (Vm_Unt)(lent+1);
    }

    montgomeryMult(	/*               -1      */
	A,		/* Result, == xyR  mod m */
	x,		/* Input operand	 */
	y,		/* Input operand	 */
	m,		/* Input operand	 */
	R,		/* Input operand	 */
	m1,		/* Input operand	 */
	t,		/* Temp			 */
	g,		/* Temp			 */
	v		/* Temp			 */
    );

    return oA;
}
#endif
    
/************************************************************************/
/*-    bnm_Exptmod -- raise a bignum to a power, modulo a third bignum	*/
/************************************************************************/

Vm_Obj
bnm_Exptmod(
    Vm_Obj ox,
    Vm_Obj oe,
    Vm_Obj om
){
    struct Bnm_Header_Rec128 xx;
    struct Bnm_Header_Rec128 xe;
    struct Bnm_Header_Rec128 xm;

    Vm_Unt lenm1 = OBJ_IS_INT(om) ? 2 : BNM_P(om)->length+1;/*+1 added quickly in debugging */
    Vm_Unt lenm2 = lenm1+1;

    Vm_Unt m1;

    Vm_Obj og   = bnm_Alloc( lenm1  , (Vm_Unt)0 );
    Vm_Obj ot   = bnm_Alloc( lenm2*2, (Vm_Unt)0 );

    Vm_Obj ou   = bnm_Alloc( lenm1  , (Vm_Unt)0 );
    Vm_Obj ov   = bnm_Alloc( lenm2*2, (Vm_Unt)0 );

    Vm_Obj oA   = bnm_Alloc( lenm1  , (Vm_Unt)0 );
    Vm_Obj oB   = bnm_Alloc( lenm2*2, (Vm_Unt)0 );
    Vm_Obj oC   = bnm_Alloc( lenm2*2, (Vm_Unt)0 );
    Vm_Obj oD   = bnm_Alloc( lenm2*2, (Vm_Unt)0 );

    Vm_Obj oR   = bnm_Alloc( lenm2  , (Vm_Unt)0 );
    Vm_Obj oX   = bnm_Alloc( lenm1,   (Vm_Unt)0 );
    Vm_Obj oM   = bnm_Alloc( lenm1,   (Vm_Unt)0 );

    Bnm_P  x;
    Bnm_P  e;
    Bnm_P  m;

    Bnm_P  g;
    Bnm_P  t;

    Bnm_P  u;
    Bnm_P  v;

    Bnm_P  A;
    Bnm_P  B;
    Bnm_P  C;
    Bnm_P  D;

    Bnm_P  R;
    Bnm_P  X;
    Bnm_P  M;

    Vm_Int start_date = job_Now();

    xx.private         = bnm_Type_Summary.builtin_class;
    xe.private         = bnm_Type_Summary.builtin_class;
    xm.private         = bnm_Type_Summary.builtin_class;

    xx.is_a            = bnm_Type_Summary.builtin_class;
    xe.is_a            = bnm_Type_Summary.builtin_class;
    xm.is_a            = bnm_Type_Summary.builtin_class;

    xx.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;    xx.length  = (Vm_Unt)1;
    xe.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;    xe.length  = (Vm_Unt)1;
    xm.physicalLength  = (Vm_Unt)MAX_BNM_BIN2DEC;    xm.length  = (Vm_Unt)1;

    if (OBJ_IS_INT(ox)) { 
	Vm_Int i = OBJ_TO_INT(ox);
	if (i < 0) {    xx.slot[0]    = -i; xx.sign = (Vm_Int)-1; }
	else {          xx.slot[0]    =  i; xx.sign = (Vm_Int) 1; }
    }	
    if (OBJ_IS_INT(oe)) { 
	Vm_Int i = OBJ_TO_INT(oe);
	if (i < 0) {    xe.slot[0]    = -i; xe.sign = (Vm_Int)-1; }
	else {          xe.slot[0]    =  i; xe.sign = (Vm_Int) 1; }
    }	
    if (OBJ_IS_INT(om)) { 
	Vm_Int i = OBJ_TO_INT(om);
	if (i < 0) {    xm.slot[0]    = -i; xm.sign = (Vm_Int)-1; }
	else {          xm.slot[0]    =  i; xm.sign = (Vm_Int) 1; }
    }	

    if (OBJ_IS_INT(ox)) x = (Bnm_P)&xx; else {
    x  = (Bnm_P) vm_Loc( ox  );	vm_Register_Hard_Pointer( &ox , (void**)&x  ); }

    if (OBJ_IS_INT(oe)) e = (Bnm_P)&xe; else {
    e  = (Bnm_P) vm_Loc( oe  );	vm_Register_Hard_Pointer( &oe , (void**)&e  ); }

    if (OBJ_IS_INT(om)) m = (Bnm_P)&xm; else {
    m  = (Bnm_P) vm_Loc( om  );	vm_Register_Hard_Pointer( &og , (void**)&m  ); }

    g  = (Bnm_P) vm_Loc( og  );	vm_Register_Hard_Pointer( &og , (void**)&g  );
    t  = (Bnm_P) vm_Loc( ot  );	vm_Register_Hard_Pointer( &ot , (void**)&t  );
    u  = (Bnm_P) vm_Loc( ou  );	vm_Register_Hard_Pointer( &ou , (void**)&u  );
    v  = (Bnm_P) vm_Loc( ov  );	vm_Register_Hard_Pointer( &ov , (void**)&v  );

    A  = (Bnm_P) vm_Loc( oA  );	vm_Register_Hard_Pointer( &oA , (void**)&A  );
    B  = (Bnm_P) vm_Loc( oB  );	vm_Register_Hard_Pointer( &oB , (void**)&B  );
    C  = (Bnm_P) vm_Loc( oC  );	vm_Register_Hard_Pointer( &oC , (void**)&C  );
    D  = (Bnm_P) vm_Loc( oD  );	vm_Register_Hard_Pointer( &oD , (void**)&D  );

    R  = (Bnm_P) vm_Loc( oR  );	vm_Register_Hard_Pointer( &oR , (void**)&R  );
    X  = (Bnm_P) vm_Loc( oX  );	vm_Register_Hard_Pointer( &oX , (void**)&X  );
    M  = (Bnm_P) vm_Loc( oM  );	vm_Register_Hard_Pointer( &oM , (void**)&M  );

    vm_Unregister_Hard_Pointer(                                 (void**)&M  );
    vm_Unregister_Hard_Pointer(                                 (void**)&X  );
    vm_Unregister_Hard_Pointer(                                 (void**)&R  );

    vm_Unregister_Hard_Pointer(                                 (void**)&D  );
    vm_Unregister_Hard_Pointer(                                 (void**)&C  );
    vm_Unregister_Hard_Pointer(                                 (void**)&B  );
    vm_Unregister_Hard_Pointer(                                 (void**)&A  );

    vm_Unregister_Hard_Pointer(                                 (void**)&v  );
    vm_Unregister_Hard_Pointer(                                 (void**)&u  );
    vm_Unregister_Hard_Pointer(                                 (void**)&t  );
    vm_Unregister_Hard_Pointer(                                 (void**)&g  );

    if (!OBJ_IS_INT(om)) 
    vm_Unregister_Hard_Pointer(                                 (void**)&m  );
    if (!OBJ_IS_INT(oe)) 
    vm_Unregister_Hard_Pointer(                                 (void**)&e  );
    if (!OBJ_IS_INT(ox)) 
    vm_Unregister_Hard_Pointer(                                 (void**)&x  );


    /* We need 0 <= x,e < m as an initial condition, with m odd: */
    if ((int)x->sign != 1) MUQ_WARN("bnm_Expmod: x cannot be negative.");
    if ((int)e->sign != 1) MUQ_WARN("bnm_Expmod: e cannot be negative.");
    if ((int)m->sign != 1) MUQ_WARN("bnm_Expmod: m cannot be negative.");
    if (x->length == 1 && x->slot[0] == (Vm_Unt)0) {
	MUQ_WARN("bnm_Expmod: x may not be zero");
    }
    if (m->length == 1 && m->slot[0] == (Vm_Unt)0) {
	MUQ_WARN("bnm_Expmod: m may not be zero");
    }
    if (!((int)m->slot[0] & 1)) {
	MUQ_WARN("bnm_Expmod: m must be odd");
    }
    if (magOrder(x,m) != LESS) {
        /* Do x = x mod m: */
	divmod(
	    A,	/* Quotient, discarded.		*/
	    B,  /* Remainder, our quarry	*/
	    C,  /* ShiftedDivisor, a temp.	*/
	    x,	/* dividend, an input		*/
	    m	/* divisor, other input.	*/
	);
        set(x,B);		
    }

    /*************************/
    /*             -1        */
    /* Set m1 to -m   mod b: */
    /*************************/

    /* Set R to b, base of one word:   */
    R->length = (Vm_Unt)2;
    R->slot[1]= (Vm_Unt)1;
    R->slot[0]= (Vm_Unt)0;

    /* Set M to m:   */
    set(M,m);

    /*                -1 		*/
    /* egcd computes m   mod b for us:	*/
    egcd(
	M,	/* Input, and gcd of 1 is returned here.		*/
	R,	/* Input, DESTROYED DURING COMPUTATION			*/
	
	g,	/* Temp.						*/
	t,	/* Scratch -- could drop if we had 2-arg add & sub.	*/
	
	u,	/* Temp.						*/
	v,	/* Temp.						*/
	
	A,	/* Temp.						*/
	B,	/* Temp.						*/
	C,	/* Temp, and desired   return value.			*/
	D	/* Temp, and discarded return value.			*/
    );
    m1 = -C->slot[0];


    /* Set R to our power-of-two radix larger than m: */
    {   int  i;
	int  mlen = (int)m->length;
	for (i = 0;  i < mlen;   ++i)   R->slot[i] = (Vm_Unt)0;
	R->slot[mlen] = (Vm_Unt)1;
	R->length     = (Vm_Unt)(mlen+1);
    }

    /* Set A to R mod m: */
    divmod(
	B,  /* Quotient, discarded.	*/
	A,  /* Remainder, our quarry	*/
	C,  /* ShiftedDivisor, a temp.	*/
	R,  /* dividend, an input	*/
	m   /* divisor, other input.	*/
    );
    
    /*           2       */
    /* Set D to R mod m: */
    mult( t, R,R );
    divmod(
	B,  /* Quotient, discarded.	*/
	D,  /* Remainder, our quarry	*/
	C,  /* ShiftedDivisor, a temp.	*/
	t,  /* dividend, an input	*/
	m   /* divisor, other input.	*/
    );

    /*                            2        */ 
    /* Set X to montgomeryMult(x,R mod m): */
    montgomeryMult(	/*               -1      */
	X,		/* Result, == xyR  mod m */
	x,		/* Input operand	 */
	D,		/* Input operand	 */
	m,		/* Input operand	 */
	R,		/* Input operand	 */
	m1,		/* Input operand	 */
	t,		/* Temp			 */
	g,		/* Temp			 */
	v		/* Temp			 */
    );
    

    /* Over all bits in the exponent,	*/
    /* most significant first (but	*/
    /* skipping leading zeros):		*/
    {   int seenNonzero = FALSE;
	int word        = e->length-1;
	for (;   word >= 0;   --word) {
	    int bit = VM_INTBITS-1;
	    for (;   bit >= 0;   --bit) {
		int bitval = (int)(e->slot[word] >> bit) & 1;
		if (bitval) seenNonzero = TRUE;
		if (seenNonzero) {

		    /* A <- Mont(A,A): */
		    montgomeryMult(	/*               -1      */
			B,		/* Result, == xyR  mod m */
			A,		/* Input operand	 */
			A,		/* Input operand	 */
			m,		/* Input operand	 */
			R,		/* Input operand	 */
			m1,		/* Input operand	 */
			t,		/* Temp			 */
			g,		/* Temp			 */
			v		/* Temp			 */
		    );
		    set(A,B);

		    if (bitval) {

			/* A <- Mont(A,X): */
			montgomeryMult(	/*               -1      */
			    B,		/* Result, == xyR  mod m */
			    A,		/* Input operand	 */
			    X,		/* Input operand	 */
			    m,		/* Input operand	 */
			    R,		/* Input operand	 */
			    m1,		/* Input operand	 */
			    t,		/* Temp			 */
			    g,		/* Temp			 */
			    v		/* Temp			 */
			);
			set(A,B);
		    }
		}
	    }
	}
    }

    /* Return montgomeryMult( A, 1 ): */
    unit(C);
    montgomeryMult(	/*               -1      */
	B,		/* Result, == xyR  mod m */
	A,		/* Input operand	 */
	C,		/* Input operand	 */
	m,		/* Input operand	 */
	R,		/* Input operand	 */
	m1,		/* Input operand	 */
	t,		/* Temp			 */
	g,		/* Temp			 */
	v		/* Temp			 */
    );
    set(A,B);

    {   Vm_Int end_date = job_Now();
	Vm_Int duration = end_date - start_date;
	if (duration > 10) {
	    lib_Log_Printf(
		"%" VM_D "-millisec exptmod done\n",
		duration
	    );
    }	}

    oA = maybeConvertToFixnum( oA, A );
    return oA;
}
    
/************************************************************************/
/*-    bnm_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj bnm_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}

/************************************************************************/
/*-    bnm_Generate_Diffie_Hellman_Key_Pair				*/
/************************************************************************/

Vm_Obj	/* Private key	*/
bnm_Generate_Diffie_Hellman_Key_Pair(
    Vm_Obj* publicKey,
    Vm_Obj  g,
    Vm_Obj  p
) {
    Vm_Obj privateKey = bnm_Alloc( (Vm_Unt)(160 / VM_INTBITS)+1, (Vm_Unt)0 );
    trulyRandomInteger( BNM_P(privateKey), 159 );
    *publicKey        = bnm_Exptmod( g, privateKey, p );
    BNM_P(privateKey)->private = BNM_DIFFIE_HELLMAN_PRIVATE_KEY; vm_Dirty(privateKey);
    return privateKey;
}

/************************************************************************/
/*-    bnm_Generate_Diffie_Hellman_Shared_Secret			*/
/************************************************************************/

Vm_Obj	/* Private key	*/
bnm_Generate_Diffie_Hellman_Shared_Secret(
    Vm_Obj  g,
    Vm_Obj  e,
    Vm_Obj  p
) {
    Vm_Obj sharedSecret          = bnm_Exptmod( g, e, p );
    BNM_P(sharedSecret)->private = BNM_DIFFIE_HELLMAN_SHARED_SECRET; vm_Dirty(sharedSecret);
    return sharedSecret;
}

 /***********************************************************************/
 /*-   bnm_byteswap_64bit_obj -- 					*/
 /***********************************************************************/

static Vm_Obj
bnm_byteswap_64bit_obj(
    Vm_Obj o
) {
    /* We're mostly 64-bit words: */
    obj_Byteswap_64bit_Obj(o);

    /* But we do have one pair of 32-bit values: */
    {   Vm_Unt tmp        = BNM_P(o)->private;
	BNM_P(o)->private = BNM_P(o)->sign;
	BNM_P(o)->sign    = tmp;
    }

    return OBJ_NIL;
}

/************************************************************************/
/*-    bnm_hash -- Return hashtable key for string.			*/
/************************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

static Vm_Obj
bnm_hash(
    Vm_Obj o
) {
    Vm_Uch buf[ MAX_STRING ];
    Bnm_P  bnm = BNM_P(o);
    int    len = (int)bnm->length;

    /* More healthy paranoia: */
    if (bnm->private)   return obj_Hash_Immediate( o );


    /* Don't overflow buffer: */
    if ((len << VM_LOG2_INTBYTES)   > MAX_STRING)   len = MAX_STRING >> VM_LOG2_INTBYTES;

    /* Copy bignum into buf[].  We need to do this  */
    /* to keep the result from depending on whether */
    /* we are on a big- or little-endian machine:   */
    {   Vm_Uch*p = buf;
        int  i;
        for (i = 0;   i < len;   ++i) {
	    Vm_Unt u = bnm->slot[i];
	    #if VM_INTBYTES==8
	    *p++ = (u >> 56) & 0xFF;
	    *p++ = (u >> 48) & 0xFF;
	    *p++ = (u >> 40) & 0xFF;
	    *p++ = (u >> 32) & 0xFF;
	    #endif 		   
	    *p++ = (u >> 24) & 0xFF;
	    *p++ = (u >> 16) & 0xFF;
	    *p++ = (u >>  8) & 0xFF;
	    *p++ = (u      ) & 0xFF;
    	}

	/* Hash buf: */
	{   Vm_Int  result = sha_InsecureHash(buf,p-buf);
	    return  result;
	}
    }
}

/************************************************************************/
/*-    bnm_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj bnm_for_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    if (key == job_Kw_Dbname) return obj_Dbname(obj);
    if (key == job_Kw_Owner)  return obj_Owner(obj);
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    bnm_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj bnm_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    bnm_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch* bnm_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    return   "May not 'set' properties on int values.";
}



/************************************************************************/
/*-    bnm_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj bnm_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    bnm_import -- Read  object from textfile.			*/
/************************************************************************/

static Vm_Obj bnm_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    Vm_Int i;
    if (1 != fscanf(fd, "%" VM_D, &i )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("bnm_import: bad input");
    }
    ++obj_Export_Stats->items_in_file;
    return OBJ_FROM_INT( i );
}



/************************************************************************/
/*-    bnm_export -- Write object into textfile.			*/
/************************************************************************/

static void bnm_export(
    FILE*  fd,
    Vm_Obj obj,
    Vm_Int write_owners
) {
    fprintf(fd, "i:%" VM_D "\n", OBJ_TO_INT( obj ) );
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





