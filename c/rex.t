@example  @c
/*--   rex.c -- Regular EXpression support for muq.			*/
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
/* Created:      94Mar30						*/
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
/*-    Overview								*/
/************************************************************************/
/*

I'm fond of Larry Wall's PERL syntax for regular expressions, which
minimizes the number of ugly backslashes needed in common expressions,
and also supports a simple rule for producing a constant expression:
When in doubt, backslash all the nonalphanumeric chars.

So, quoting semantics fairly directly from the Programming Perl book:

o  Alternatives are separated by '|' and evaluated right-to-left,
   stopping on first complete match.

o  Assertions are ^ (start) $ (end) \b (word boundary \w\W) \B (!\b)

o  Quantifiers are
  {n,m}  at least n, no more than m matches
  {n,}   at least n
  {n}    exactly n
  *      {0,}
  +      {1,}
  ?      {0,1}

o (rex) matches what rex matches
o .     matches anything but \n
o [abc] matches any of a b c
  [^abc] matches anything but a b or c
  [a-c]  matches any of a b c
  [a\-c] matches any of a - c
  \b in range is backspace. \d\w\s\n\r\t\f \nnn work as below
o \n newline \r CR \t tab \f formfeed \d [0-9] \D [^0-9]
  \w [0-9a-zA-Z] \w [^0-9a-zA-Z] \s [ \t\n\r\f] \S [^ \t\n\r\f]
o \0 matches null
o \1 ... \9 matches what () pair n matched. \10 etc ok if present,
  and no leading zero. ()* (etc) returns last match in series.
o \033 etc (2-3 digit octal) matches that byte value
o \x7F (2digits) matches hex byte val
o \cD matches control-D
o Other backslashed chars match selves;
o other chars match selves.

 */


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


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

static void rex_doTypes(void){}
Obj_A_Module_Summary rex_Module_Summary = {
   "rex",
    rex_doTypes,
    rex_Startup,
    rex_Linkup,
    rex_Shutdown
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    rex_Init -- Initialize a Rex_Job_Rec to empty.			*/
/************************************************************************/

void
rex_Init(
    struct Rex_Job_Rec* r
) {
    r->string    = OBJ_FROM_INT(0);
    r->stringLen = OBJ_FROM_INT(0);
    r->bufTop    = OBJ_FROM_INT(0);
    r->bufBot    = OBJ_FROM_INT(0);
    r->cursor    = OBJ_FROM_INT(0);

    {   int  i;
	for (i = REX_MAX_MATCHES;   i --> 0;  ) {
	    r->matchTop[i] = OBJ_FROM_INT(0);
	    r->matchBot[i] = OBJ_FROM_INT(0);
    }	}

    {   int  i;
	for (i = REX_MAX_MATCHES;   i --> 0;  ) {
	    r->buf[i] = OBJ_FROM_INT(0);
    }	}
}


/************************************************************************/
/*-    rex_Cache -- Update global cache from job record.		*/
/************************************************************************/

void
rex_Cache(
    struct Rex_Job_Rec* r
) {
    if (r->string == OBJ_FROM_INT(0)) {
	job_Rex.string = OBJ_FROM_INT(0);
	return;
    }
    job_Rex = *r;
}

/************************************************************************/
/*-    rex_Uncache -- Update job record from global cache.		*/
/************************************************************************/

void
rex_Uncache(
    struct Rex_Job_Rec* r
) {
    if (job_Rex.string == OBJ_FROM_INT(0)) {
	r->string = OBJ_FROM_INT(0);
	return;
    }
    *r = job_Rex;
    job_Rex.string = OBJ_FROM_INT(0);
}

/************************************************************************/
/*-    validate -- Make sure global cache contains given char range	*/
/************************************************************************/

/************************************************************************/
/* I'm expecting we'll eventually have a variety of different string	*/
/* implementations in Muq, possibly including implementations using	*/
/* shared memory, implementations using host files, implementations	*/
/* using 16-bit unicode chars, and tree-structured implementations	*/
/* supporting efficient insert/delete operations.  One of the rex.t	*/
/* design goals here is to keep most of the regular expression pattern	*/
/* matching machinery insulated from the string implementation(s) via	*/
/* job_Rex.buf[], leaving only validate() to be aware of the different	*/
/* implementation issues.  (Assuming stg.t doesn't hide them all.)	*/
/* By fetching a bufferload at a time, I hope to amortize the string	*/
/* access overhead enough to yield acceptable performance even on	*/
/* fairly intricate string implementations.				*/
/************************************************************************/

static Vm_Int
validate(
    Vm_Int top,
    Vm_Int bot
) {
    Vm_Uch buf[ REX_MAX_BUF ];
    Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
    Vm_Int bufBot = OBJ_TO_INT( job_Rex.bufBot );
    Vm_Int len    = OBJ_TO_INT( job_Rex.stringLen );

    /* Sanity checks: */
    #if MUQ_IS_PARANOID
    if (top < 0
    ||  bot < top
    ||  bot-top > REX_MAX_BUF
    ){
	MUQ_WARN("validate: internal err");
    }
    #endif

    /* Trivial success/fail conditions: */
    if (bot <= bufBot && top >= bufTop)   return TRUE;
    if (bot >  len)                       return FALSE;

    /* Ok, need to update buffer contents.  */
    /* Lets try to read as much potentially */
    /* useful stuff into it as practical,   */
    /* not just the requested subsequence:  */
    if (bot-top < REX_MAX_BUF) {
	bot = top+REX_MAX_BUF;
	if (bot > len) {
	    bot = len;
	    if (bot-top < REX_MAX_BUF) {
		top = bot-REX_MAX_BUF;
		if (top < 0) {
		    top = 0;
		}
	    }
	}
    }

    /* Do the actual read from the string: */
    #if MUQ_IS_PARANOID
    {   Vm_Int  i = stg_Get_Bytes( buf, bot-top, job_Rex.string, top );
	if (i != bot-top)   MUQ_WARN("validate: internal err3");
    }
    #else
    stg_Get_Bytes( buf, bot-top, job_Rex.string, top );
    #endif

    /* Update the job_Rex buffer from our local buf[]: */
    {   int k = bot-top;
	int i;
	for (i = 0;   i < k;   ++i) {
	    job_Rex.buf[i] = OBJ_FROM_CHAR(buf[i]);
	}
	job_Rex.bufTop = OBJ_FROM_INT(top);
	job_Rex.bufBot = OBJ_FROM_INT(bot);
	return TRUE;
    }
}

/************************************************************************/
/*-    rex_Begin -- Set global cache to match given string.		*/
/************************************************************************/

void
rex_Begin(
    Vm_Obj str
) {
    /*****************************************************/
    /* Note that the garbage collector is unaware of our */
    /* job_Rex state record, so it is important that we  */
    /* enter stg into j->rex.string rather than just	 */
    /* job_Rex.string.                                   */
    /*****************************************************/
 
    Vm_Int ilen = stg_Len(str);
    Vm_Obj len = OBJ_FROM_INT(ilen);

    if (!stg_Is_Stg(str)) MUQ_WARN("Regular expressions only match strings");

    {   Job_P j = JOB_P( job_RunState.job );
	rex_Init( &j->rex );
	j->rex.string = str;
	j->rex.stringLen = len;
	j->rex.bufTop    = OBJ_FROM_INT(0);
	j->rex.bufBot    = OBJ_FROM_INT(0);
	j->rex.cursor    = OBJ_FROM_INT(0);
	job_Rex          = j->rex;
	vm_Dirty(job_RunState.job);
    }

    if (ilen <= REX_MAX_BUF)    validate( 0, ilen        );
    else                        validate( 0, REX_MAX_BUF );
}

/************************************************************************/
/*-    rex_End -- Clear match state to inactive				*/
/************************************************************************/

void
rex_End(
    void
) {
    {   Job_P j = JOB_P( job_RunState.job );
	rex_Init( &j->rex );
	job_Rex  = j->rex;
	vm_Dirty(job_RunState.job);
    }
}

/************************************************************************/
/*-    rex_Open_Paren -- Mark start of a matched substring		*/
/************************************************************************/

void
rex_Open_Paren(
    Vm_Int which
) {
    job_Rex.matchTop[which] = job_Rex.cursor;
}

/************************************************************************/
/*-    rex_Close_Paren -- Mark end of a matched substring		*/
/************************************************************************/

void
rex_Close_Paren(
    Vm_Int which
) {
    job_Rex.matchBot[which] = job_Rex.cursor;
}

/************************************************************************/
/*-    rex_Cancel_Paren -- Clear substring to unmatched status		*/
/************************************************************************/

void
rex_Cancel_Paren(
    Vm_Int which
) {
    job_Rex.matchTop[which] = OBJ_FROM_INT(0);
    job_Rex.matchBot[which] = OBJ_FROM_INT(0);
}

/************************************************************************/
/*-    rex_Match_Previous_Match -- Match string matched by parenpair	*/
/************************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

Vm_Obj
rex_Match_Previous_Match(
    Vm_Int which
) {
    Vm_Uch buf0[ MAX_STRING ];
    Vm_Uch buf1[ MAX_STRING ];
    Vm_Int start  = OBJ_TO_INT( job_Rex.matchTop[which] );
    Vm_Int stop   = OBJ_TO_INT( job_Rex.matchBot[which] );
    int    mlen   = (int)(stop-start);
    Vm_Obj str    = job_Rex.string;
    Vm_Int slen   = OBJ_TO_INT( job_Rex.stringLen );
    Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor    );
    if (mlen + cursor > slen) return OBJ_NIL;
    if (OBJ_IS_INT(str))      return OBJ_NIL;
    if (mlen > MAX_STRING) {
	MUQ_WARN("rexMatchPreviousMatch: implemention length limit exceeded");
    }
    if (mlen != stg_Get_Bytes( buf0, mlen, str, start )) {
	MUQ_WARN("rexMatchPreviousMatch internal err0");
    }
    if (mlen != stg_Get_Bytes( buf1, mlen, str, cursor )) {
	MUQ_WARN("rexMatchPreviousMatch internal err1");
    }
    {   int i;
        for (i = 0;   i < mlen;   ++i) {
	    if (buf0[i] != buf1[i])   return OBJ_NIL;
    }	}
    job_Rex.cursor = OBJ_FROM_INT( cursor + mlen );
    return OBJ_T;
}

/************************************************************************/
/*-    rex_Get_Paren -- Clear substring to unmatched status		*/
/************************************************************************/

Vm_Obj
rex_Get_Paren(
    Vm_Obj* stop,
    Vm_Int  which
) {
    *stop = job_Rex.matchBot[which];
    return  job_Rex.matchTop[which];
}

/************************************************************************/
/*-    rex_Done_P -- TRUE iff all of string has been matched		*/
/************************************************************************/

Vm_Int
rex_Done_P(
    void
) {
    return   job_Rex.cursor == job_Rex.stringLen;
}

/************************************************************************/
/*-    rex_Match_Char_Class -- Match [a-zA-Z0-9] type stuff		*/
/************************************************************************/

/************************************************************************/
/* We actually take our argument as a string like "a-zA-Z0-9" or such.	*/
/* It might seem silly to leave the expansion until runtime instead of	*/
/* doing it at regex compile time, but I couldn't think of any way I	*/
/* liked better to represent the pre-expanded character set, especially	*/
/* keeping in mind the possiblity of adding unicode support:		*/
/*									*/
/* Representing the charset as a bitmap using fixnums would mean	*/
/* 128 bits ==> 3 62-bit fixnums for US-ASCII, and 			*/
/* 256 bits ==> 6 62-bit fixnums for 8-bit European ascii variants.	*/
/* That seems awkward, even ignoring unicode.				*/
/*									*/
/* Representing the charset as a bitmap using bignums would be less	*/
/* awkward, but bignums have a lot of overhead:  using a 256-bit fixnum */
/* to represent something like "0-9" grates on my nerves.		*/
/*									*/
/* Representing the charset as a bytemap wouldn't be much better.	*/
/*									*/
/* All in all, just interpreting patterns like "a-zA-Z0-9" at runtime	*/
/* seems likely to be just about as fast in practice, and lots simpler	*/
/* and more compact, plus we have a natural path (UTF-8?) via which to	*/
/* add support for unicode we decide we need it.			*/
/************************************************************************/

Vm_Obj
rex_Match_Char_Class(
    Vm_Obj str
) {
    Vm_Uch buf[ REX_MAX_BUF ];
    int len = (int) stg_Len( str );
    if (len > REX_MAX_BUF)   MUQ_WARN("rex_Match_Char_Class: constant string too long");

    #if MUQ_IS_PARANOID
    {   Vm_Int  i = stg_Get_Bytes( buf, len, str, (Vm_Int)0 );
	if (i != len)   MUQ_WARN("rex_Match_Char_Class: internal err");
    }
    #else
    stg_Get_Bytes( buf, len, str, (Vm_Unt)0 );
    #endif

    {   Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor );
	Vm_Int curend = cursor + 1;
        if (!validate( cursor, curend ))  return OBJ_NIL;
	{   Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
	    int    offset = (int)(cursor-bufTop);
            Vm_Obj c      = job_Rex.buf[offset];
	    int i;
	    if (buf[0] == '^') {
		/* Negated character range: */
		for (i = 1;   i < len;   ++i) {
		    if (i+2 < len   && buf[i+1]=='-') {
			/* Try matching a range of characters: */
			if (OBJ_FROM_CHAR(buf[i  ]) <= c
			&&  OBJ_FROM_CHAR(buf[i+2]) >= c
			){
			    return OBJ_NIL;
			}
			i += 2;
		    } else {	
			/* Try matching a single character in class: */
			if (OBJ_FROM_CHAR(buf[i]) == c) {
			    return OBJ_NIL;
			}
		    }
		}
		job_Rex.cursor = OBJ_FROM_INT( curend );
		return OBJ_T;
	    } else {
		/* Non-negated character range: */
		for (i = 0;   i < len;   ++i) {
		    if (i+2 < len   && buf[i+1]=='-') {
			/* Try matching a range of characters: */
			if (OBJ_FROM_CHAR(buf[i  ]) <= c
			&&  OBJ_FROM_CHAR(buf[i+2]) >= c
			){
			    job_Rex.cursor = OBJ_FROM_INT( curend );
			    return OBJ_T;
			}
			i += 2;
		    } else {	
			/* Try matching a single character in class: */
			if (OBJ_FROM_CHAR(buf[i]) == c) {
			    job_Rex.cursor = OBJ_FROM_INT( curend );
			    return OBJ_T;
			}
		    }
		}
	    }
        }
        return OBJ_NIL;
    }
}

/************************************************************************/
/*-    rex_Match_String -- Match constant string			*/
/************************************************************************/

Vm_Obj
rex_Match_String(
    Vm_Obj str
) {
    Vm_Uch buf[ REX_MAX_BUF ];
    int len = (int) stg_Len( str );
    if (len > REX_MAX_BUF)   MUQ_WARN("rex_Match_String: constant string too long");

    #if MUQ_IS_PARANOID
    {   Vm_Int  i = stg_Get_Bytes( buf, len, str, (Vm_Int)0 );
	if (i != len)   MUQ_WARN("rex_Match_String: internal err");
    }
    #else
    stg_Get_Bytes( buf, len, str, (Vm_Unt)0 );
    #endif

    {   Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor );
	Vm_Int curend = cursor + len;
	int i;
        if (!validate( cursor, curend ))  return OBJ_NIL;
	{   Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
	    int offset    = (int)(cursor-bufTop);
	    for (i = 0;  i < len;   ++i) {
		if (OBJ_FROM_CHAR(buf[i]) != job_Rex.buf[i+offset]) {
		    return OBJ_NIL;
		}
	    }
	}
	job_Rex.cursor = OBJ_FROM_INT( curend );
    }

    return OBJ_T;
}

/************************************************************************/
/*-    rex_Match_Dot -- Match anything but newline			*/
/************************************************************************/

Vm_Obj
rex_Match_Dot(
    void
) {
    {   Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor );
	Vm_Int curend = cursor + 1;
        if (!validate( cursor, curend ))  return OBJ_NIL;
	{   Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
	    int offset    = (int)(cursor-bufTop);
	    if (OBJ_FROM_CHAR('\n') == job_Rex.buf[offset]) {
		return OBJ_NIL;
	    }
	}
	job_Rex.cursor = OBJ_FROM_INT( curend );
    }

    return OBJ_T;
}

/************************************************************************/
/*-    rex_Match_Wordboundary -- Match word boundary			*/
/************************************************************************/

Vm_Obj
rex_Match_Wordboundary(
    void
) {
    {   Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor );
	Vm_Int curend = cursor + 1;
        if (!validate( cursor, curend ))  return OBJ_NIL;
	{   Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
	    int offset    = (int)(cursor-bufTop);
	    if (OBJ_FROM_CHAR('\n') == job_Rex.buf[offset]) {
		return OBJ_NIL;
	    }
	}
	job_Rex.cursor = OBJ_FROM_INT( curend );
    }

    return OBJ_T;
}

/************************************************************************/
/*-    rex_Match_Wordchar -- Match [a-zA-Z0-9_]				*/
/************************************************************************/

Vm_Obj
rex_Match_Wordchar(
    void
) {
    Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor );
    Vm_Int curend = cursor + 1;
    if (!validate( cursor, curend ))  return OBJ_NIL;
    {   Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
	int offset    = (int)(cursor-bufTop);
	int c         = OBJ_TO_CHAR(job_Rex.buf[offset]);
	if ((c&~0xFF) || (!isalnum(c) && c!='_')) {
	    return OBJ_NIL;
	}
    }
    job_Rex.cursor = OBJ_FROM_INT( curend );

    return OBJ_T;
}

/************************************************************************/
/*-    rex_Match_Digit -- Match [0-9]					*/
/************************************************************************/

Vm_Obj
rex_Match_Digit(
    void
) {
    Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor );
    Vm_Int curend = cursor + 1;
    if (!validate( cursor, curend ))  return OBJ_NIL;
    {   Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
	int offset    = (int)(cursor-bufTop);
	int c         = OBJ_TO_CHAR(job_Rex.buf[offset]);
	if ((c&~0xFF) || !isdigit(c)) {
	    return OBJ_NIL;
	}
    }
    job_Rex.cursor = OBJ_FROM_INT( curend );

    return OBJ_T;
}

/************************************************************************/
/*-    rex_Match_Whitespace -- 						*/
/************************************************************************/

Vm_Obj
rex_Match_Whitespace(
    void
) {
    Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor );
    Vm_Int curend = cursor + 1;
    if (!validate( cursor, curend ))  return OBJ_NIL;
    {   Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
	int offset    = (int)(cursor-bufTop);
	int c         = OBJ_TO_CHAR(job_Rex.buf[offset]);
	if ((c&~0xFF) || !isspace(c)) {
	    return OBJ_NIL;
	}
    }
    job_Rex.cursor = OBJ_FROM_INT( curend );

    return OBJ_T;
}

/************************************************************************/
/*-    rex_Match_Nonwordboundary -- Match word boundary			*/
/************************************************************************/

Vm_Obj
rex_Match_Nonwordboundary(
    void
) {
    {   Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor );
	Vm_Int curend = cursor + 1;
        if (!validate( cursor, curend ))  return OBJ_NIL;
	{   Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
	    int offset    = (int)(cursor-bufTop);
	    if (OBJ_FROM_CHAR('\n') == job_Rex.buf[offset]) {
		return OBJ_NIL;
	    }
	}
	job_Rex.cursor = OBJ_FROM_INT( curend );
    }

    return OBJ_T;
}

/************************************************************************/
/*-    rex_Match_Nonwordchar -- Match [^a-zA-Z0-9_]				*/
/************************************************************************/

Vm_Obj
rex_Match_Nonwordchar(
    void
) {
    Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor );
    Vm_Int curend = cursor + 1;
    if (!validate( cursor, curend ))  return OBJ_NIL;
    {   Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
	int offset    = (int)(cursor-bufTop);
	int c         = OBJ_TO_CHAR(job_Rex.buf[offset]);
	if (!(c&~0xFF) && (isalnum(c) || c=='_')) {
	    return OBJ_NIL;
	}
    }
    job_Rex.cursor = OBJ_FROM_INT( curend );

    return OBJ_T;
}

/************************************************************************/
/*-    rex_Match_Nondigit -- Match [^0-9]				*/
/************************************************************************/

Vm_Obj
rex_Match_Nondigit(
    void
) {
    Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor );
    Vm_Int curend = cursor + 1;
    if (!validate( cursor, curend ))  return OBJ_NIL;
    {   Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
	int offset    = (int)(cursor-bufTop);
	int c         = OBJ_TO_CHAR(job_Rex.buf[offset]);
	if (!(c&~0xFF) && isdigit(c)) {
	    return OBJ_NIL;
	}
    }
    job_Rex.cursor = OBJ_FROM_INT( curend );

    return OBJ_T;
}

/************************************************************************/
/*-    rex_Match_Nonwhitespace -- 					*/
/************************************************************************/

Vm_Obj
rex_Match_Nonwhitespace(
    void
) {
    Vm_Int cursor = OBJ_TO_INT( job_Rex.cursor );
    Vm_Int curend = cursor + 1;
    if (!validate( cursor, curend ))  return OBJ_NIL;
    {   Vm_Int bufTop = OBJ_TO_INT( job_Rex.bufTop );
	int offset    = (int)(cursor-bufTop);
	int c         = OBJ_TO_CHAR(job_Rex.buf[offset]);
	if (!(c&~0xFF) && isspace(c)) {
	    return OBJ_NIL;
	}
    }
    job_Rex.cursor = OBJ_FROM_INT( curend );

    return OBJ_T;
}

/************************************************************************/
/*-    rex_Get_Cursor -- Get current location within string		*/
/************************************************************************/

Vm_Obj
rex_Get_Cursor(
    void
) {
    return job_Rex.cursor;
}

/************************************************************************/
/*-    rex_Set_Cursor -- Set current location within string		*/
/************************************************************************/

void
rex_Set_Cursor(
    Vm_Obj cursor
) {
    Vm_Unt cur = OBJ_TO_INT( cursor            );
    Vm_Unt len = OBJ_TO_INT( job_Rex.stringLen );
    if (cur > len)   MUQ_WARN("rex_Set_Cursor: out-of-range cursor value");
    job_Rex.cursor = cursor;
}

/************************************************************************/
/*-    --- Standard Public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    rex_Startup -- start-of-world stuff.				*/
/************************************************************************/

void rex_Startup ( void ) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;
}



/************************************************************************/
/*-    rex_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void rex_Linkup ( void ) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    rex_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void rex_Shutdown ( void ) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/



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
