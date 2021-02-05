@example  @c
/*--   int.c -- INTegral numbers for Muq.				*/
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
/* Created:      94Mar06						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1995, by Jeff Prothero.				*/
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
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/



/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static Vm_Uch*    int_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj     int_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     int_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     int_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch*    int_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj     int_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     int_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void       int_export(  FILE*, Vm_Obj, Vm_Int );

static void       int_startup( void			);
static void       int_linkup(  void			);
static void       int_shutdown(void			);


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

Obj_A_Type_Summary int_Type_Summary = {    OBJ_FROM_BYT1('i'),
    int_sprintX,
    int_sprintX,
    int_sprintX,
    int_for_del,
    int_for_get,
    int_g_asciz,
    int_for_set,
    int_for_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Dummy_Reverse,
    obj_Type_Get_Mos_Key,
    int_import,
    int_export,
    /* 98Mar08CrT: Changing next to "Integer" results in bytecode divergence  */
    /* at bytecode 12443, processing 'number in 020-C-mos.t, and an eventual  */
    /* coredump with bad dbref on last test in x-mos.  I've no clue why and   */
    /* don't want to spend more than the halfday I already have on it, so I'm */
    /* leaving it "integer" for now (buggo?).  See also "symbol" in sym.t --  */
    /* this appears to be the only other such case.                           */
    "integer",
    KEY_LAYOUT_FIXNUM,
    OBJ_0
};

static void int_doTypes(void){
    if (mod_Type_Summary[ OBJ_TYPE_INT ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_INT");
    }

    mod_Type_Summary[ OBJ_TYPE_INT ] = &int_Type_Summary;
}
Obj_A_Module_Summary int_Module_Summary = {
   "int",
    int_doTypes,
    int_startup,
    int_linkup,
    int_shutdown
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Standard Static fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    int_startup -- start-of-world stuff.				*/
/************************************************************************/

static void int_startup ( void ) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

}



/************************************************************************/
/*-    int_linkup -- start-of-world stuff.				*/
/************************************************************************/

static void int_linkup ( void ) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    int_shutdown -- end-of-world stuff.				*/
/************************************************************************/

static void int_shutdown ( void ) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}




/************************************************************************/
/*-    int_sprintX -- Debug dump of int state, multi-line format.	*/
/************************************************************************/

static Vm_Uch* int_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    return  lib_Sprint( buf, lim, "%" VM_D, OBJ_TO_INT(obj) );
}



/************************************************************************/
/*-    int_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj int_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    int_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj int_for_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    int_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj int_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    int_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch* int_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    return   "May not 'set' properties on int values.";
}



/************************************************************************/
/*-    int_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj int_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    int_import -- Read  object from textfile.			*/
/************************************************************************/

static Vm_Obj int_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    Vm_Int i;
    if (1 != fscanf(fd, "%" VM_D, &i )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("int_import: bad input");
    }
    ++obj_Export_Stats->items_in_file;
    return OBJ_FROM_INT( i );
}



/************************************************************************/
/*-    int_export -- Write object into textfile.			*/
/************************************************************************/

static void int_export(
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
