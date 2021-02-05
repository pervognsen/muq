@example  @c
/*--   bot.c -- BOTtom values for Muq.					*/
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
/* JEFF PROTHERO DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	*/
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

static Vm_Uch*    bot_sprintX(  Vm_Uch*, Vm_Uch*, Vm_Obj, Vm_Int );
static Vm_Obj     bot_for_del( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     bot_for_get( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     bot_g_asciz( Vm_Obj, Vm_Uch*, Vm_Int );
static Vm_Uch*    bot_for_set( Vm_Obj, Vm_Obj , Vm_Obj, Vm_Int );
static Vm_Obj     bot_for_nxt( Vm_Obj, Vm_Obj , Vm_Int );
static Vm_Obj     bot_import(  FILE*, Vm_Int, Vm_Int, Vm_Int );
static void       bot_export(  FILE*, Vm_Obj, Vm_Int );

static void       bot_startup( void			);
static void       bot_linkup(  void			);
static void       bot_shutdown(void			);



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

Obj_A_Type_Summary bot_Type_Summary = {    OBJ_FROM_BYT1('u'),
    bot_sprintX,
    bot_sprintX,
    bot_sprintX,
    bot_for_del,
    bot_for_get,
    bot_g_asciz,
    bot_for_set,
    bot_for_nxt,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Dummy_Reverse,
    obj_Type_Get_Mos_Key,
    bot_import,
    bot_export,
    "Bottom",
    KEY_LAYOUT_BOTTOM,
    OBJ_0
};

static void bot_doTypes(void){
    if (mod_Type_Summary[ OBJ_TYPE_BOTTOM ] != &obj_Type_Bad_Summary) {
	MUQ_FATAL ("Some type conflicts with OBJ_TYPE_BOTTOM");
    }
    mod_Type_Summary[ OBJ_TYPE_BOTTOM ] = &bot_Type_Summary;
}
Obj_A_Module_Summary bot_Module_Summary = {
    "bot",
    bot_doTypes,
    bot_startup,
    bot_linkup,
    bot_shutdown
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Standard Static fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    bot_startup -- start-of-world stuff.				*/
/************************************************************************/

static void bot_startup ( void ) {

    static int done_startup = FALSE;
    if        (done_startup)   return;
    done_startup	    = TRUE;

}



/************************************************************************/
/*-    bot_linkup -- start-of-world stuff.				*/
/************************************************************************/

static void bot_linkup ( void ) {

    static int done_linkup  = FALSE;
    if        (done_linkup)   return;
    done_linkup		    = TRUE;
}



/************************************************************************/
/*-    bot_shutdown -- end-of-world stuff.				*/
/************************************************************************/

static void bot_shutdown ( void ) {

    static int done_shutdown = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	     = TRUE;
}




/************************************************************************/
/*-    bot_sprintX -- Debug dump of bot state, multi-line format.	*/
/************************************************************************/

static Vm_Uch* bot_sprintX(
    Vm_Uch* buf,
    Vm_Uch* lim,
    Vm_Obj  obj,
    Vm_Int  qot
) {
    return  lib_Sprint( buf, lim, "#undefined#" );
}



/************************************************************************/
/*-    bot_for_del -- Property delete code.				*/
/************************************************************************/

static Vm_Obj bot_for_del(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    bot_for_get -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj bot_for_get(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    bot_g_asciz -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj bot_g_asciz(
    Vm_Obj  obj,
    Vm_Uch* key,
    Vm_Int  propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    bot_for_set -- Property store code.				*/
/************************************************************************/

static Vm_Uch* bot_for_set(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Obj val,
    Vm_Int propdir
) {
    return   "May not 'set' properties on bottom values.";
}



/************************************************************************/
/*-    bot_for_nxt -- Property fetch code.				*/
/************************************************************************/

static Vm_Obj bot_for_nxt(
    Vm_Obj obj,
    Vm_Obj key,
    Vm_Int propdir
) {
    return OBJ_NOT_FOUND;
}



/************************************************************************/
/*-    bot_import -- Read  object from textfile.			*/
/************************************************************************/

static Vm_Obj bot_import(
    FILE*  fd,
    Vm_Int pass,
    Vm_Int have,
    Vm_Int read
) {
    int i;
    if (1 != fscanf(fd, "%d", &i )
    ||  fgetc(fd) != '\n'
    ){
	MUQ_FATAL ("bot_import: bad input");
    }
    ++obj_Export_Stats->items_in_file;
    return OBJ_FROM_BOTTOM( i );
}



/************************************************************************/
/*-    bot_export -- Write object into textfile.			*/
/************************************************************************/

static void bot_export(
    FILE*  fd,
    Vm_Obj obj,
    Vm_Int write_owners
) {
    fprintf(fd, "u:%d\n", (int)OBJ_TO_BOTTOM( obj ) );
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
