@example  @c
/*--   spc.c -- SPeCial values for Muq.					*/
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
/* Please send bug reports/fixes etc to bugs@@muq.orgu.			*/
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

static Vm_Uch*    spc_sprintX( Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj     spc_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     spc_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     spc_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch*    spc_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj     spc_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     spc_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void       spc_export(  FILE*, Vm_Obj, Vm_Int );

static void       spc_startup( void			);
static void       spc_linkup(  void			);
static void       spc_shutdown(void			);


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

Obj_A_Type_Summary spc_Type_Summary = {    OBJ_FROM_BYT1('s'),
    spc_sprintX,
    spc_sprintX,
    spc_sprintX,
    spc_for_del,
    spc_for_get,
    spc_g_asciz,
    spc_for_set,
    spc_for_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Dummy_Reverse,
    obj_Type_Get_Mos_Key,
    spc_import,
    spc_export,
    "Special",
    OBJ_0
};

static void spc_doTypes(void){
    if (mod_Type_Summary[ OBJ_TYPE_SPECIAL ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_SPECIAL");
    }

    mod_Type_Summary[ OBJ_TYPE_SPECIAL ] = &spc_Type_Summary;
}
Obj_A_Module_Summary spc_Module_Summary = {
   "spc",
    spc_doTypes,
    spc_startup,
    spc_linkup,
    spc_shutdown
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Standard Static fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    spc_startup -- start-of-world stuff.				*/
/************************************************************************/

static void spc_startup ( void ) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

}



/************************************************************************/
/*-    spc_linkup -- start-of-world stuff.				*/
/************************************************************************/

static void
spc_linkup(
    void
){
    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    spc_shutdown -- end-of-world stuff.				*/
/************************************************************************/

static void
spc_shutdown(
    void
){
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}




/************************************************************************/
/*-    spc_sprintX -- Debug dump of spc state, multi-line format.	*/
/************************************************************************/

static Vm_Uch*
spc_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    /* At present, at least, OBJ_NOT_FOUND           */
    /* should never be accessable to the muf hacker. */
    /* But we code up display of it anyhow:          */
    switch (obj) {
    case OBJ_FIRST:       return lib_Sprint(buf,lim,"#<firstKey>");
    case OBJ_NOT_FOUND:   return lib_Sprint(buf,lim,"#<objNotFound>");
    case OBJ_BLOCK_START: return lib_Sprint(buf,lim,"[");
    case OBJ_NULL_DIL:    return lib_Sprint(buf,lim,"#<nullHashedBtree>");
    case OBJ_NULL_SIL:    return lib_Sprint(buf,lim,"#<nullSortedBtree>");
/* buggo, need a hack here to support ephemerals. */
    default:		
	return lib_Sprint(buf,lim,"#<UNKNOWN SPECIAL OBJ?!>");
    }
}



/************************************************************************/
/*-    spc_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj
spc_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    spc_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj spc_for_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    spc_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj spc_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    spc_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch* spc_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    return   "May not 'set' properties on special values.";
}



/************************************************************************/
/*-    spc_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj spc_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    spc_import -- Read  object from textfile.			*/
/************************************************************************/

static Vm_Obj
spc_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    int i;
    if (1 != fscanf(fd, "%d", &i )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("spc_import: bad input");
    }
    ++obj_Export_Stats->items_in_file;
/* Ephemerals prolly need special handling here. */
    return OBJ_FROM_SPECIAL( i );
}



/************************************************************************/
/*-    spc_export -- Write object into textfile.			*/
/************************************************************************/

static void
spc_export(
    FILE*  fd,
    Vm_Obj obj,
    Vm_Int write_owners
) {
/* Ephemerals prolly need special handling here. */
    fprintf(fd, "s:%d\n", (int)OBJ_TO_SPECIAL( obj ) );
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
