/* - 210-C-muc-parser.y -- BYACC grammar for Multi-User-C.		*/
/* - This file is formatted for outline-minor-mode in emacs19.		*/
/* -^C^O^A shows All of file.						*/
/*  ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)	*/
/*  ^C^O^T hides all Text. (Leaves all headings.)			*/
/*  ^C^O^I shows Immediate children of node.				*/
/*  ^C^O^S Shows all of a node.						*/
/*  ^C^O^D hiDes all of a node.						*/
/*  ^HFoutline-mode gives more details.					*/
/*  (Or do ^HI and read emacs:outline mode.)				*/

/* ====================================================================	*/
/* - Dedication and Copyright.						*/

/* -------------------------------------------------------------------  */
/*									*/
/*		For Firiss:  Aefrit, a friend.				*/
/*									*/
/* -------------------------------------------------------------------  */

/* -------------------------------------------------------------------  */
/* Author:       Jeff Prothero						*/
/* Created:      99Sep19						*/
/* Modified:								*/
/* Language:     MUF							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/*  Copyright (c) 2000, by Jeff Prothero.				*/
/* 									*/
/* This program is free software; you may use, distribute and/or modify	*/
/* it under the terms of the GNU Library General Public License as      */
/* published by	the Free Software Foundation; either version 2, or at   */
/* your option	any later version FOR NONCOMMERCIAL PURPOSES.		*/
/*									*/
/* COMMERCIAL operation allowable at $100/CPU/YEAR.			*/
/* COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.		*/
/* Other commercial arrangements NEGOTIABLE.				*/
/* Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.			*/
/* 									*/
/*   This program is distributed in the hope that it will be useful,	*/
/*   but WITHOUT ANY WARRANTY; without even the implied warranty of	*/
/*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	*/
/*   GNU Library General Public License for more details.		*/
/* 									*/
/*   You should have received a copy of the GNU General Public License	*/
/*   along with this program: COPYING.LIB; if not, write to:		*/
/*      Free Software Foundation, Inc.					*/
/*      675 Mass Ave, Cambridge, MA 02139, USA.				*/
/* 									*/
/* Jeff Prothero DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	*/
/* INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN	*/
/* NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR	*/
/* CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	*/
/* OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		*/
/* NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	*/
/* WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.			*/
/* 									*/
/* Please send bug reports/fixes etc to bugs@@muq.org.			*/
/* -------------------------------------------------------------------	*/

/* I currently compile this file in this directory via			
      byacc -vd 210-C-muc-parser.y;  ../bin/muq-byacc-to-muf >210-C-muc-parser.muf.t
   and then do a normal Muq build.  It is normal to get one shift-	*/
/* reduce conflict, due to the "dangling else" syntax ambiguity		*/
/* normal to C-like languages, which byacc will resolve properly.	*/


/*=====================================================================*/
/*- Quote			             			       */
/*								       */
/*    "I would be most content if my children grew up		       */
/*     to be the kind of people who think decorating		       */
/*     consists mostly of building enough bookshelves."		       */
/*				-- Anna Quindlen		       */
/*								       */
/*=====================================================================*/



/* Standard reserved words: */
%token AUTO      257
%token BREAK     258
%token CASE      259
%token CHAR      260
%token CONST     261
%token CONTINUE  262
%token DEFAULT   263
%token DO        264 
%token DOUBLE    265 
%token ELSE      266 
%token ENUM      267
%token EXTERN    268
%token FLOAT     269
%token FOR       270
%token GOTO      271
%token IF        272
%token INT       273
%token LONG      274
%token REGISTER  275
%token RETURN    275
%token SHORT     276
%token SIGNED    277
%token SIZEOF    278
%token STATIC    279
%token STRUCT    280
%token SWITCH    281
%token TYPEDEF   282
%token UNION     283
%token UNSIGNED  284
%token VOID      285
%token VOLATILE  286
%token WHILE     287

/* Plain identifier: */
%token ID        289

/* The various primitive constant types: */
%token STR_CNST  290
%token FLT_CNST  291
%token INT_CNST  292
%token CHR_CNST  293
%token OCT_CNST  294
%token HEX_CNST  295

/* Digraphs and trigraphs: */
%token ADD_SET       /* +=  */  296
%token AMPAMP        /* &&  */  297
%token AMP_SET       /* &=  */  298
%token BARBAR        /* ||  */  299
%token BAR_SET       /* |=  */  300
%token DASHMORE      /* ->  */  301
%token DOTDOTDOT     /* ... */  302
%token EQUAL         /* ==  */  303
%token TILDA_SET     /* ~=  */  304
%token HAT_SET       /* ^=  */  305
%token LESSLESS      /* <<  */  306
%token LESSLESS_SET  /* <<= */  307
%token LESS_OR_EQ    /* <=  */  308
%token MOREMORE      /* >>  */  309
%token MOREMORE_SET  /* >>= */  310
%token MORE_OR_EQ    /* >=  */  311
%token MORE_OR_LESS  /* ><  */  312
%token NOT_EQ        /* !=  */  313
%token PCNT_SET      /* %=  */  314
%token PLUSPLUS      /* ++  */  315
%token PLUSSLASH     /* +/  */  316
%token SLASH_SET     /* /=  */  317
%token STARSLASH     /* * / */  318
%token STARSTAR      /* **  */  319
%token STAR_SET      /* *=  */  320
%token SUBSUB        /* --  */  321
%token SUB_SET       /* -=  */  322

%token DOLLAR_ID 340
%token REGEX     341 /* For x = /regex/ string;		   */

/* Nonstandard reserved words: */
%token AFTER     350
%token BIT       351 /* For bitvector declarations.        */
%token BYTE      352
%token CILK      353 /* Reserved for Cilk syntax support.  */
%token CLASS     354 /* For class declarations & variables */
%token DELETE    355 /* To delete properties from indices. */
%token EQ        356
%token GE        357
%token GENERIC   358 /* For CLOS-style generic functions.  */
%token GT        359
%token INLET     360 /* Reserved for Cilk syntax support.  */
%token LE        361
%token LT        362
%token MACRO     363 /* For lisp-style macros.             */
%token METHOD    364 /* For CLOS-style methods.            */
%token NE        365
%token NORETURN  366 /* For functions which do not return. */
%token OBJ       367
%token PRIVATE   368 /* Opposite of public                 */
%token PUBLIC    369 /* Opposite of private                */
%token SPAWN     370 /* Reserved for Cilk syntax support.  */
%token SYNC      371 /* Reserved for Cilk syntax support.  */
%token TRY       372 /* For error trapping.                */
%token WITH      373 /* For with-lock-do and such.         */
%token ENDIF     374 /* For #if ... #endif hack.	   */
%token WHEN      375 /* For asynch op syntax.		   */

/* Should we support/steal C++ 'new' syntax such as 'new int [18]'?  */
/* Should we support/steal C++ 'this' syntax for 'self' in a method? */

/* If you change the above token numberings, */
/* be sure to update the matching #defines   */
/* in joba.t:job_P_Next_Muc_Token_In_String  */

%start toplevel

%%

/**********************/
/* Expression syntax: */
/**********************/
atom    : ID		{ "[ 'v' $1 ] --> $$"; }
	| DOLLAR_ID	{ "[ 'P' $1 ] --> $$"; }
        | CHR_CNST
        | HEX_CNST
        | INT_CNST
        | FLT_CNST
        | OCT_CNST
        | STR_CNST
        |                    '(' put   ')'	    { "          $2      --> $$"; }
        |                    '{' conds '}'	    { "[ '}' 'v' $2 ]   --> $$"; }
        | '(' OBJ    '*' ')' '{' conds '}'	    { "[ '}' 'v' $2 ]   --> $$"; }
        | '(' BYTE   '*' ')' '{' conds '}'	    { "[ '}' 'c' $2 ]   --> $$"; }
        | '(' CHAR   '*' ')' '{' conds '}'	    { "[ '}' 'c' $2 ]   --> $$"; }
        | '(' SHORT  '*' ')' '{' conds '}'	    { "[ '}' 's' $2 ]   --> $$"; }
        | '(' INT    '*' ')' '{' conds '}'	    { "[ '}' 'i' $2 ]   --> $$"; }
        | '(' FLOAT  '*' ')' '{' conds '}'	    { "[ '}' 'f' $2 ]   --> $$"; }
        | '(' DOUBLE '*' ')' '{' conds '}'	    { "[ '}' 'd' $2 ]   --> $$"; }
	|     '.' ID  { "[ '.' [ '(' [ 'v' \"root\" ] [ ' ' ] ] $1 ] --> $$"; }
	| '@' '.' ID  { "[ '.' [ '(' [ 'v' \"job\"  ] [ ' ' ] ] $1 ] --> $$"; }
	|  FLOAT '[' conds ']'			/* This syntax reserved */
	|  FLOAT '[' conds ']' '{' conds '}'	/* for anonymous arrays */
        ;

postfix : atom
        | postfix '[' cond      ']'	{ "[ '[' $4 $2 ] --> $$"; }
	| postfix '(' opt_args  ')'	{ "[ '(' $4 $2 ] --> $$"; }
        | postfix '.' ID		{ "[ '.' $3 $1 ] --> $$"; }
        | postfix     PLUSPLUS		{ "[ '+' $2    ] --> $$"; }
        | postfix     SUBSUB		{ "[ '-' $2    ] --> $$"; }
        | postfix     STARSTAR atom	{ "[ 'muf:expt $3 $1 ] --> $$"; }
        ;

lval    : postfix
        | PLUSPLUS    lval    { "[ 'p'            $1 ] --> $$"; }
        | SUBSUB      lval    { "[ 's'            $1 ] --> $$"; }
        | '+'         lval    { "                 $1    --> $$"; }
        | '-'         lval    { "[ 'muf:neg       $1 ] --> $$"; }
        | '~'         lval    { "[ 'muf:lognot    $1 ] --> $$"; }
        | '!'         lval    { "[ 'muf:not       $1 ] --> $$"; }
        | '|'         lval    { "[ 'muf:abs       $1 ] --> $$"; }
        | '='         lval    { "[ 'muf:magnitude $1 ] --> $$"; }
        | '#'         lval    { "[ 'muf:length2   $1 ] --> $$"; }
        | PLUSSLASH   lval    { "[ 'muf:sum       $1 ] --> $$"; }
        | STARSLASH   lval    { "[ 'muf:product   $1 ] --> $$"; }
/*      | SIZEOF      lval */
        ;     /* NB: 'x = /regex/ string;' pre-empts unary '/'. */

cross   :           	     lval
        | cross MORE_OR_LESS lval	{ "[ 'muf:crossProduct $3 $1 ] --> $$"; }
        ;

dot     :           cross
        | cross '!' cross       { "[ 'muf:dotProduct $3 $1 ] --> $$"; }
        ;

term    :          dot
        | term '*' dot		{ "[ 'muf:* $3 $1 ] --> $$"; }
        | term '/' dot		{ "[ 'muf:/ $3 $1 ] --> $$"; }
        | term '%' dot		{ "[ 'muf:% $3 $1 ] --> $$"; }
        ;

sum     :         term
        | sum '+' term		{ "[ 'muf:+ $3 $1 ] --> $$"; }
        | sum '-' term		{ "[ 'muf:- $3 $1 ] --> $$"; }
        ;

shift   :                sum
        | shift LESSLESS sum	{ "[ 'muf:ash $3 $1 ] --> $$"; }
        | shift MOREMORE sum	{ "[ 'muf:ash $3 [ 'muf:neg $1 ] ] --> $$"; }
        ;

less    :                 shift
        | less '<'        shift	{ "[ 'muf:lt    $3 $1 ] --> $$"; }
        | less '>'        shift	{ "[ 'muf:gt    $3 $1 ] --> $$"; }
        | less LESS_OR_EQ shift	{ "[ 'muf:le    $3 $1 ] --> $$"; }
        | less MORE_OR_EQ shift	{ "[ 'muf:ge    $3 $1 ] --> $$"; }
        | less LT         shift	{ "[ 'muf:lt_ci $3 $1 ] --> $$"; }
        | less GT         shift	{ "[ 'muf:gt_ci $3 $1 ] --> $$"; }
        | less LE         shift	{ "[ 'muf:le_ci $3 $1 ] --> $$"; }
        | less GE         shift	{ "[ 'muf:ge_ci $3 $1 ] --> $$"; }
        ;

eq      :           less
        | eq '~'    less	{ "[ 'muf:nearlyEqual $3 $1 ] --> $$"; }
        | eq EQUAL  less	{ "[ 'muf:eq          $3 $1 ] --> $$"; }
        | eq NOT_EQ less	{ "[ 'muf:ne          $3 $1 ] --> $$"; }
        | eq EQ     less	{ "[ 'muf:eq_ci       $3 $1 ] --> $$"; }
        | eq NE     less	{ "[ 'muf:ne_ci       $3 $1 ] --> $$"; }
        ;

amp     :         eq
        | amp '&' eq		{ "[ 'muf:logand $3 $1 ] --> $$"; }
        ;

xor     :         amp
        | xor '^' amp		{ "[ 'muf:logxor $3 $1 ] --> $$"; }
        ;

or      :        xor
        | or '|' xor		{ "[ 'muf:logior $3 $1 ] --> $$"; }
        ;

ampamp  :               or
        | ampamp AMPAMP or		{ "[ '&' $3 $1 ] --> $$"; }
        ;

barbar  :               ampamp
        | barbar BARBAR ampamp		{ "[ '|' $3 $1 ] --> $$"; }
        ;

cond    : barbar
        | barbar '?' put ':' cond	{ "[ '?' $5 $3 $1 ] --> $$"; }
        ;

assn_op : STAR_SET			{ "'muf:*      --> $$"; }
	| SLASH_SET    			{ "'muf:/      --> $$"; }
	| PCNT_SET     			{ "'muf:%      --> $$"; }
	| ADD_SET      			{ "'muf:+      --> $$"; }
	| SUB_SET      			{ "'muf:-      --> $$"; }
	| LESSLESS_SET 			{ "'muf:ash    --> $$"; }
	| MOREMORE_SET	/* buggo */
	| AMP_SET      			{ "'muf:logand --> $$"; }
	| HAT_SET      			{ "'muf:logxor --> $$"; }
	| BAR_SET			{ "'muf:logior --> $$"; }
        ;

regex   : REGEX cond			{ "[ '(' $2 $1 ] --> $$"; }
	;

put     : cond
	| conds TILDA_SET regex		{ "[ '=' $3 $1    ] --> $$"; }
        | conds '='       args		{ "[ '=' $3 $1    ] --> $$"; }
	| lval assn_op    cond		{ "[ '%' $3 $2 $1 ] --> $$"; }
        ;

const   : cond ;

opt_args: /* empty */ 			{ "[ ' ' ] --> $$"; }
	| args
	;

arg	: cond
	| body 				{ "[ 'a' $1 ] --> $$"; }
	;

args    :            arg
        | args  ','  arg		{ "[ ',' $3 $1 ] --> $$"; }
        ;

conds   :           cond
        | conds ',' cond		{ "[ ',' $3 $1 ] --> $$"; }
        ;

opt_put : /* empty */ 			{ "[ ' ' ] --> $$"; }
        | put
        ;



/**********************/
/* Statement synxtax: */
/**********************/

basetype : OBJ
	 | FLOAT
	 | DOUBLE
	 | LONG
	 | INT
	 | CHAR
	 | BIT
	 | BYTE
	 | NORETURN
	 | VOID
	 ;

typeexpr : basetype
	 |         typeexpr '*'
	 ;

typeexprs:               typeexpr
	 | typeexprs ',' typeexpr	{ "[ ',' $2 $1 ] --> $$"; }
	 ;

type     :           typeexpr
         | REGISTER  typeexpr		{ "$1 --> $$"; }
	 ;

array	 : '[' ']'
	 ;

vardecl  : type ID			{ "$1 --> $$"; }
	 | type ID array		{ "$2 --> $$"; }
	 ;

param    : vardecl
         | ID
	 ;

params   :            param
	 | params ',' param		{ "[ ',' $3 $1 ] --> $$"; }
	 ;

paramsopt: /* empty */
	 | params
	 | VOID				{ "nil --> $$"; }
	 ;

fundecl  :                vardecl
	 | typeexprs ','  vardecl	{ "[ ',' $2 $1 ] --> $$"; }
         ;

body     : '{'              '}'		{ "[ ' '    ] --> $$"; }
         | '{' statements   '}'		{ "[ '{' $2 ] --> $$"; }
	 ;

macro	 :         ID body		/* This syntax is just reserved */
	 |  macro  ID body		/* for user-defined code macros */
	 ;

statement: opt_put          ';'
         | '#' IF '(' cond  ')'		{ "[ '#' $2         ] --> $$"; }
         | '#' IF     ID  		{ "[ '#' [ 'v' $1 ] ] --> $$"; }
         | '#' ELSE			{ "[ '#' nil        ] --> $$"; }
         | '#' ENDIF			{ "[ ' '            ] --> $$"; }
         | GOTO ID          ';'		{ "[ 'g' $2         ] --> $$"; }
	 | BREAK            ';'		{ "[ 'b'            ] --> $$"; }
         | CONTINUE         ';'		{ "[ 'c'            ] --> $$"; }
	 | RETURN 	    ';' 	{ "[ 'r'            ] --> $$"; }
	 | RETURN put       ';' 	{ "[ 'r' $2         ] --> $$"; }
         | '^'              ';' 	{ "[ 'r'            ] --> $$"; }
         | '^'    put       ';' 	{ "[ 'r' $2         ] --> $$"; }
	 | DELETE postfix   ';' 	{ "[ 'z' $2         ] --> $$"; }
	 | vardecl          ';'		{ "[ 'V' $2         ] --> $$"; }
         | vardecl '=' cond ';'		{ "[ ';'   [ 'V' $4 ]   [ '=' [ 'v' $4 ] $2 ]  ] --> $$"; }
	 | body
	 | macro	    ';'					{ "[ 'M' ] --> $$"; } /* For asynch ops */
	 | WHEN conds '=' postfix '(' opt_args  ')' body	{ "[ 'W' ] --> $$"; } /* For asynch ops */
	 | fundecl '(' paramsopt ')' ';'			{ "[ 'F' $5 $3 nil ] --> $$"; }
	 | fundecl '(' paramsopt ')' body			{ "[ 'F' $5 $3 $1  ] --> $$"; }
         | ID               ':' statement 			{ "[ 't' $3 $1    ] --> $$"; }
         | CASE const       ':' statement 			{ "[ 'C' $3 $1    ] --> $$"; }
         | DEFAULT          ':' statement 			{ "[ 'D' $1       ] --> $$"; }
         | IF     '(' put   ')' statement			{ "[ 'i' $3 $1    ] --> $$"; }
         | IF     '(' put   ')' statement ELSE statement  	{ "[ 'I' $5 $3 $1 ] --> $$"; }
	 | SWITCH '(' put   ')' statement 			{ "[ 'S' $3 $1    ] --> $$"; }
         | WHILE  '(' put   ')' statement			{ "[ 'w' $3 $1    ] --> $$"; }
         | DO statement WHILE '(' put ')' ';'			{ "[ 'd' $6 $3 ] --> $$"; }
         | FOR    '(' opt_put ';' opt_put ';' opt_put ')' statement	{ "[ 'f' $7 $5 $3 $1 ] --> $$"; }
         ;

statements:            statement
          | statements statement	{ "[ ';' $2 $1 ] --> $$"; }
          ;

toplevel  :            statement	{ "$1 --> $$   $$ evalParsetree"; }
          | toplevel   statement	{ "$1 --> $$   $$ evalParsetree"; }
          ;


%%



( Global variable to hold string being parsed: )
nil --> _yyinput                '_yyinput export
( Global variable to hold offset within string being parsed: )
nil --> _yyinputoffset          '_yyinputoffset export
( Global variable to hold function to read in next line: )
nil --> _yyreadlinefn           '_yyreadlinefn export
nil --> _yyisinteractive        '_yyisinteractive export

( Forward declaration of 211-C-muq-compiler.t function: )
:   evalParsetree { $ -> } pop ;

( yylex -- called by yyparse: )
:   yylex { $ -> $ }
    -> yylast

    do{
        ( Read next token: )
	@.yyinput @.yycursor yylast nextMucTokenInString
	--> @.yycursor
	->  yytokenstart
	->  type

        ( Special hack to read and return regular expressions: )
	type REGEX = if
	    @.yyinput @.yycursor muf:compileRexString --> @.yycursor --> @.yylval ( cfn )
	    REGEX return
	fi

        ( Done if token is not end-of-input flag: )
	type 0 != if loopFinish fi

        ( Done if no function specified to read new input: )
	@.yyreadfn not if loopFinish fi

	( Read one new line of input and append to input string: )
        @.yyinput   @.yyreadfn call{ -> $ }   join  --> @.yyinput
    }

    @.yyinput yytokenstart @.yycursor type mucTokenValueInString
    --> @.yylval
    @.yyinput yytokenstart @.yycursor substring -> token
    @.yydebug if [ "yylex: returning token %s type %d val %s\n" token type @.yylval | ]print , fi
    type
;

( yyerror -- called by yyparse: )
: yyerror { $ -> } "yyerror: " , , "\n" , ;


