@example  @c

/*--   err.c -- Simple error logging fn.				*/
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
/* Created:      93Feb01						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1993-1995, by Jeff Prothero.				*/
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
/* Date:    Fri, 14 Oct 1994 04:20:02 -0600				*/
/* From:    qotd-request@ensu.ucalgary.ca (Quote of the day)		*/
/* To:      qotd@ensu.ucalgary.ca					*/
/* Subject: Quote of the day						*/
/*									*/
/* The requirements for admission to practice law include completion of	*/
/* general education at the university level; completion of a three-year*/
/* postgraduate law school curriculum; passing a two- or three-day	*/
/* written bar examination; and proof of satisfactory character, the	*/
/* latter requirement being minimal.					*/
/*                              G.C. Hazard Jr. and Michele Taruffo	*/
/*                              _American Civil Procedure_ 1993		*/
/*									*/
/*    Submitted by:   "KENNETH J. LABACH" <KL2483@STUDENT.LAW.DUKE.EDU> */
/*                       Sep. 4, 1994					*/
/*       -------------------------------------------------------------- */
/*                       Send quotes to qotd@ensu.ucalgary.ca		*/
/*       Send list changes or requests to qotd-request@ensu.ucalgary.ca	*/
/************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    err -- log error message.					*/
/************************************************************************/

void err(
    FILE* f,
    Vm_Uch* title,
    Vm_Uch *format, ...
) {
    va_list args;
    Vm_Uch format2[1024];
    Vm_Uch buffer[ 1024];

    strcpy(     format2, "**** "   );
    if (title && *title) {
        strcat( format2, title     );
        strcat( format2, " **** "  );
    }
    strcat(     format2, format    );
    strcat(     format2, "\n"      );
    va_start(args, format);
    vsprintf(buffer, format2, args);
    va_end(args);
    fputs(buffer,f);
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
