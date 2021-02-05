@example  @c
/* buggo: need to get all the for_get and g_asciz fns agreeing on */
/* whether to return OBJ_NIL or OBJ_NOT_FOUND. */

/*--   mod.c -- Central module tables etc..				*/
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
/*-    Quote								*/
/*									*/
/*     "The difference between genius and stupidity			*/
/*	is that genius has its limits."					*/
/*				-- Albert Einstein			*/
/************************************************************************/


/************************************************************************/
/*-    Overview								*/
/************************************************************************/
/* 

This file is an initial step toward making it cheap to add
new classes and modules to Muq.  Ideally, we should be able
to add new classes and modules to Muq without, in general,
needing to recompile the central Muq files.

Muq can then be simply a library which (multiple)
applications link against, and development can proceed by
simply recompiling one module, rather than by needing to
frequently recompile the complete core fileset for Muq.

(My past experience has been that developers of hybrid
applications detest having to routinely recompile the core
interpreter.)

This file contains:

 -> An index of all modules.
    (Used by obj.c in issuing startup/linkup/shutdown calls.)

 -> An index of classes.
    (Used by obj.c in looking up hardwired properties.)

*/


/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    mod_Hardcoded_Class[] -- indexed by OBJ_CLASS(o).		*/
/************************************************************************/

Obj_Hardcoded_Class mod_Hardcoded_Class[ OBJ_CLASS_MAX ] = {

    /* dum: */ &obj_Hardcoded_Dum_Class,
    /*root: */ &usr_Hardcoded_Rot_Class,
    /* usr: */ &usr_Hardcoded_Usr_Class,
    /* gst: */ &usr_Hardcoded_Gst_Class,
    /* fun: */ &fun_Hardcoded_Class,
    /* asm: */ &asm_Hardcoded_Class,
    /* job: */ &job_Hardcoded_Class,
    /* obj: */ &obj_Hardcoded_Obj_Class,
    /* skt: */ &skt_Hardcoded_Class,
    /* mss: */ &mss_Hardcoded_Class,
    /* ssn: */ &ssn_Hardcoded_Class,
    /* jbs: */ &jbs_Hardcoded_Class,
    /* stk: */ &stk_Hardcoded_Class,
    /* lst: */ &lst_Hardcoded_Class,
    /* dst: */ &dst_Hardcoded_Class,
    /* stm: */ &stm_Hardcoded_Class,
    /* pkg: */ &pkg_Hardcoded_Class,
    /* sys: */ &sys_Hardcoded_Class,
    /* muq: */ &muq_Hardcoded_Class,
    /* lok: */ &lok_Hardcoded_Class,
    /* prx: */ &prx_Hardcoded_Class,
    /* cfg: */ &cfg_Hardcoded_Class,
    /* joq: */ &joq_Hardcoded_Class,
    /* usq: */ &usq_Hardcoded_Class,
    /* cdf: */ &cdf_Hardcoded_Class,
    /* key: */ &key_Hardcoded_Class,
    /* mtd: */ &mtd_Hardcoded_Class,
    /* lbd: */ &lbd_Hardcoded_Class,
    /* rdt: */ &rdt_Hardcoded_Class,
    /* dil: */ &dil_Hardcoded_Class,
    /* din: */ &din_Hardcoded_Class,
    /* pil: */ &pil_Hardcoded_Class,
    /* pin: */ &pin_Hardcoded_Class,
    /* sil: */ &sil_Hardcoded_Class,
    /* sin: */ &sin_Hardcoded_Class,
    /* til: */ &til_Hardcoded_Class,
    /* tin: */ &tin_Hardcoded_Class,
    /* mil: */ &mil_Hardcoded_Class,
    /* min: */ &min_Hardcoded_Class,
    /* sel: */ &sel_Hardcoded_Class,
    /* sen: */ &sen_Hardcoded_Class,
    /* dbf: */ &dbf_Hardcoded_Class,
    /* set: */ &set_Hardcoded_Class,
    /* ndx: */ &ndx_Hardcoded_Class,
    /* n3d: */ &n3d_Hardcoded_Class,
    /* hsh: */ &hsh_Hardcoded_Class,
    /* ary: */ &ary_Hardcoded_Class,
    /* tbl: */ &tbl_Hardcoded_Class,
    /* wdw: */ &wdw_Hardcoded_Class,
    /* d3l: */ &d3l_Hardcoded_Class,
    /* d3n: */ &d3n_Hardcoded_Class,

    /* Commented out because nobody is working */
    /* on completing the X support: */
    /* xdp:  / &xdp_Hardcoded_Class, */
    /* xft:  / &xft_Hardcoded_Class, */
    /* xgc:  / &xgc_Hardcoded_Class, */
    /* xsc:  / &xsc_Hardcoded_Class, */
    /* xwd:  / &xwd_Hardcoded_Class, */
    /* xcl:  / &xcl_Hardcoded_Class, */
    /* xcm:  / &xcm_Hardcoded_Class, */
    /* xcr:  / &xcr_Hardcoded_Class, */
    /* xpx:  / &xpx_Hardcoded_Class, */

    /* Include patches for optional modules: */
    #define  MODULES_OBJ_C_HARDCODED_CLASS
    #include "Modules.h"
    #undef   MODULES_OBJ_C_HARDCODED_CLASS
};



/************************************************************************/
/*-    mod_Module_Summary[] -- null-terminated list of module summaries. */
/************************************************************************/

Obj_Module_Summary mod_Module_Summary[ ] = {
    /* dum: */ &obj_Module_Summary,
    /*root: */ &usr_Module_Summary,
    /* usr: */ &usr_Module_Summary,
    /* fun: */ &fun_Module_Summary,
    /* asm: */ &asm_Module_Summary,
    /* job: */ &job_Module_Summary,
    /* obj: */ &obj_Module_Summary,
    /* skt: */ &skt_Module_Summary,
    /* mss: */ &mss_Module_Summary,
    /* ssn: */ &ssn_Module_Summary,
    /* jbs: */ &jbs_Module_Summary,
    /* stk: */ &stk_Module_Summary,
    /* stm: */ &stm_Module_Summary,
    /* pkg: */ &pkg_Module_Summary,
    /* sys: */ &sys_Module_Summary,
    /* muq: */ &muq_Module_Summary,
    /* joq: */ &joq_Module_Summary,
    /* lst: */ &lst_Module_Summary,
    /* muf: */ &muf_Module_Summary,
    /* sym: */ &sym_Module_Summary,
    /* stg: */ &stg_Module_Summary,
    /* flt: */ &flt_Module_Summary,
    /* int: */ &int_Module_Summary,
    /* bot: */ &bot_Module_Summary,
    /* spc: */ &spc_Module_Summary,
    /* chr: */ &chr_Module_Summary,
    /* vec: */ &vec_Module_Summary,
    /* stc: */ &stc_Module_Summary,
    /* ecn: */ &ecn_Module_Summary,
    /* est: */ &est_Module_Summary,
    /* evc: */ &evc_Module_Summary,
    /* cfn: */ &cfn_Module_Summary,
    /* rex: */ &rex_Module_Summary,
    /* lok: */ &lok_Module_Summary,
    /* blk: */ &blk_Module_Summary,
    /* evt: */ &evt_Module_Summary,
    /* prx: */ &prx_Module_Summary,
    /* cfg: */ &cfg_Module_Summary,
    /* usq: */ &usq_Module_Summary,
    /* cdf: */ &cdf_Module_Summary,
    /* key: */ &key_Module_Summary,
    /* mtd: */ &mtd_Module_Summary,
    /* lbd: */ &lbd_Module_Summary,
    /* rdt: */ &lbd_Module_Summary,
    /* clo: */ &clo_Module_Summary,
    /* dil: */ &dil_Module_Summary,
    /* pil: */ &pil_Module_Summary,
    /* sil: */ &sil_Module_Summary,
    /* til: */ &til_Module_Summary,
    /* mil: */ &mil_Module_Summary,
    /* sel: */ &sel_Module_Summary,
    /* bnm: */ &bnm_Module_Summary,
    /* dbf: */ &dbf_Module_Summary,
    /* ndx: */ &ndx_Module_Summary,
    /* n3d: */ &n3d_Module_Summary,
    /* hsh: */ &hsh_Module_Summary,
    /* ary: */ &ary_Module_Summary,
    /* tbl: */ &tbl_Module_Summary,
    /* set: */ &set_Module_Summary,
    /* i01: */ &i01_Module_Summary,
    /* i16: */ &i16_Module_Summary,
    /* i32: */ &i32_Module_Summary,
    /* f32: */ &f32_Module_Summary,
    /* f64: */ &f64_Module_Summary,
    /* ogl: */ &ogl_Module_Summary,
    /* wdw: */ &wdw_Module_Summary,
    /* d3l: */ &d3l_Module_Summary,

    /* Commented out because nobody is working */
    /* on completing the X support: */
    /* xdp:  / &xdp_Module_Summary, */
    /* xft:  / &xft_Module_Summary, */
    /* xgc:  / &xgc_Module_Summary, */
    /* xsc:  / &xsc_Module_Summary, */
    /* xwd:  / &xwd_Module_Summary, */
    /* xcl:  / &xcl_Module_Summary, */
    /* xcm:  / &xcm_Module_Summary, */
    /* xcr:  / &xcr_Module_Summary, */
    /* xpx:  / &xpx_Module_Summary, */

    /* Include patches for optional modules: */
    #define  MODULES_OBJ_C_MODULE_SUMMARY
    #include "Modules.h"
    #undef   MODULES_OBJ_C_MODULE_SUMMARY

    /* End-of-array sentinel: */
    NULL
};



/************************************************************************/
/*-    mod_Type_Summary[] -- array of type summaries.			*/
/************************************************************************/

/* There can be, with current encodings, at most 24 types:      */
/*  1 int type with       *******0 tag;				*/
/* 15 explicit types with ***????1 tags;			*/
/*  8 implicit types with ???00001 tags.			*/
/* This array is filled out by the various xxx_Startup()s:	*/
Obj_Type_Summary mod_Type_Summary[ OBJ_TYPE_MAX ];




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
