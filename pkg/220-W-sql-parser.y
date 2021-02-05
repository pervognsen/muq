/* - 220-C-sql-parser.y -- BYACC grammar for Muq SQL.			*/
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
/* Created:      99Oct17						*/
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
      byacc -vd 220-W-sql-parser.y;  ../bin/muq-byacc-to-muf >220-C-sql-parser.muf.t
   and then do a normal Muq build.  					*/

%start		program


/* COMMANDS */
%token		APPEND	COPY	CREATE	DELETE	DESTROY	HELP	INDEX	MODIFY
%token		PRINT	RANGE	REPLACE	RETRIEVE	SAVE		
%token		DEFINE	PERMIT	VIEW	INTEGRITY
%token		DELIM	USE	UNUSE

/* 'NOISE' WORDS */
%token		ALL	BY	FROM	IN	INTO	UNIQUE	AT
%token		IS	OF	ON	ONTO	TO	UNTIL	WHERE

/* CONSTANTS */
%token		NAME	SCONST	I2CONST	I4CONST F4CONST	F8CONST

/* PUNCTUATION */
%token		COMMA	LPAREN	PERIOD	RPAREN	COLON	BGNCMNT	ENDCMNT
%token		LBRAC	RBRAC	DOLLAR	PCT

/* UNARY ARITHMETIC OPERATORS */
%token		UAOP

/* BINARY ARITHMETIC OPERATORS */
%token		BAOP	BAOPH

/* BOUNDS OPERATORS */
%token		BDOP

/* EQUALITY OPERATORS */
%token		EOP

/* LOGICAL OPERATORS */
%token		LBOP	LUOP

/* FUNCTIONAL OPERATORS */
%token		FOP	FBOP

/* AGGREGATE OPERATORS */
%token		AGOP

/* TYPES FOR INGRES TOKENS */
%type	<type_type>	IS
%type	<string_type>	NAME	SCONST
%type	<I2_type>	I2CONST
%type	<I4_type>	I4CONST
%type	<F4_type>	F4CONST
%type	<F8_type>	F8CONST
%type	<type_type>	UAOP
%type	<type_type>	BAOP	BAOPH
%type	<type_type>	BDOP
%type	<type_type>	EOP
%type	<type_type>	LBOP	LUOP
%type	<type_type>	FOP	FBOP
%type	<type_type>	AGOP
%type   <I4_type>	LPAREN	RPAREN	LBRAC	RBRAC  PCT

/* DEFINE ASCENDING PRECEDENCE FOR OPERATORS */
%left		LBOP
%left		LUOP
%left		UAOP
%left		BAOP
%left		BAOPH
%nonassoc	unaryop

%%
program :	program stmnt
	|	        stmnt
        ;
stmnt   :	append
	|	copy
	|	create
	|	delete 	
	|	destroy
	|	help
	|	index	
	|	integrity
	|	modify
	|	permit
	|	print
	|	range
	|	replace	
	|	retrieve 
	|	save
	|	view
	|	use
	|	unuse
	|	delim	
	|	error
        ;

range   :	rngstmnt OF NAME IS NAME
	;

rngstmnt:	RANGE
	;

append  :	apstmnt apto relation tlclause qualclause
	;
apstmnt :	APPEND
	;
apto:		INTO
	|	ONTO
	|	TO
	|	ON
	|
	;

delete  :	delstmnt delwd relation qualclause
	;

delstmnt:	DELETE
	;

delwd	:	IN
	|	ON
	|	FROM
	|
	;

replace :	repstmnt repkwd relation tlclause qualclause
	;

repstmnt:	REPLACE
	;

repkwd  :	INTO
	|	IN
	|	ON
	|
	;

retrieve:	retstmnt retclause tlclause qualclause
	;

retstmnt:	RETRIEVE
	;

retclause:	retkwd relation
	 |
	 |	UNIQUE
	 ;

retkwd  :	INTO
	|	TO
	|
	;

delim   :	DEFINE DELIM NAME LPAREN NAME COMMA SCONST RPAREN
	;

use	:	USE NAME
  	;

unuse   :	UNUSE NAME
	;

view	:	viewclause tlclause qualclause
	;

viewclause:	viewstmnt relation
	  ;

viewstmnt:	DEFINE VIEW
	 ;

permit   :	permstmnt permlist permrel permtarg permwho permplace permtd qualclause
	 ;

permstmnt:	DEFINE PERMIT
	 ;

permlist:	permxlist
	|	permlist COMMA permxlist
	;

permxlist:	ALL
	|	RETRIEVE
	|	DELETE
	|	APPEND
	|	REPLACE
	;

permrel :	permword relation
	;

permword:	ON
	|	OF
	|	TO
	;

permtarg:	LPAREN permtlist RPAREN
	|
	;

permtlist:	permtlelm
	 |	permtlist COMMA permtlelm
	 ;

permtlelm:	NAME
	 ;

permwho :	TO NAME
	|	TO ALL
	;

permplace:	AT NAME
	|	AT ALL
	|
	;

permtd  :	permtime permday
	|	permdeftime permday
	|	permtime permdefday
	|	permdeftime permdefday
	;

permdeftime:
	   ;

permdefday:
	  ;

permtime:	FROM I2CONST COLON I2CONST TO I2CONST COLON I2CONST
	;

permday :	ON NAME TO NAME
	;

integrity:	integstmnt integnoise relation integis qual
	 ;

integstmnt:	DEFINE INTEGRITY
	  ;

integnoise:	ON
	  |	ONTO
	  |	IN
	  |	OF
	  |	/* null */
	  ;

integis :	IS
	|	/* null*/
	;

relation:	NAME
	;

tlclause:	LPAREN tlist RPAREN
	;

tlist   :	tlelm
	|	tlist COMMA tlelm
	;

tlelm   :	NAME is afcn
	|	attrib
	|	var PERIOD ALL
	;

is	:	IS
	|	BY
	;

qualclause:	where qual
	  |
	  ;

where   :	WHERE
	;

qual    :	LPAREN qual RPAREN
	|	LUOP qual
	|	qual LBOP qual
	|	clause
	;

clause  :	afcn relop afcn
	;

relop   :	EOP
	|	IS
	|	BDOP
	;

afcn    :	aggrfcn
	|	attribfcn
	|	afcn BAOPH afcn
	|	afcn BAOP afcn
	|	afcn UAOP afcn
	|	LPAREN afcn RPAREN
	|	uop afcn	%prec unaryop
	|	FOP LPAREN afcn RPAREN
	|	FBOP LPAREN afcn COMMA afcn RPAREN
	;

aggrfcn :	AGOP LPAREN afcn BY domseq qualclause RPAREN
	|	AGOP LPAREN afcn qualclause RPAREN
	;
domseq  :	targdom
	|	domseq COMMA targdom
	;

targdom :	afcn
	;

nameprt :	NAME
	|	SCONST
	;
subelm  :	DOLLAR
	|	nameprt DOLLAR
	|	nameprt
	|	I2CONST subelm
	;
grpelm  :	subelm COMMA subelm
	;

leftclose:	PCT
	|	LPAREN
	;

rightclose:	PCT
	|	RPAREN
	;

stringpart:	leftclose subelm rightclose
	|	leftclose grpelm rightclose
	;

attrib  :	var PERIOD NAME
	|   	attrib stringpart
	;

var	:	NAME
	;

attribfcn:	I2CONST
	|	I4CONST
	|	F4CONST
	|	F8CONST
	|	SCONST
	|	NAME
	|	attrib
	;

uop	:	UAOP	%prec unaryop
	;
copy	:	copstmnt alias LPAREN coparam RPAREN keywd SCONST
	;

copstmnt:	COPY
	;

coparam :	cospecs
	|
	;

cospecs :	alias is coent
	|	cospecs COMMA alias is coent
	;

coent	:	alias
	|	SCONST
	;

alias	:	NAME
	;

specs	:	alias is alias
	|	specs COMMA alias is alias
	;

keywd	:	INTO
	|	FROM
	;
create	:	crestmnt alias LPAREN specs RPAREN
	;

crestmnt:	CREATE
	;

destroy	:	destmnt keys
	|	destqm destlist
	|	destmnt DELIM NAME
	;

destmnt	:	DESTROY
	;

destqm	:	destmnt INTEGRITY NAME
	|	destmnt PERMIT NAME
	;

destlist:	I2CONST
	|	destlist COMMA I2CONST
	|	ALL
	;

help	:	helstmnt hlist
	|	helstmnt
	|	helqmstmnt hqmlist
	|	heldelstmnt
	|	heldelstmnt dlist
	;

helstmnt:	HELP
	;

heldelstmnt:	HELP DELIM
	   ;

helqmstmnt:	HELP VIEW
	|	HELP PERMIT
	|	HELP INTEGRITY
	;

hlist	:	hparam
	|	hlist COMMA hparam
	|	ALL
	;
dlist	:	dparam
	|	dlist COMMA dparam
	;

dparam	:	NAME
	;

hparam	:	NAME
	|	SCONST
	;

hqmlist	:	NAME
	|	hqmlist COMMA NAME
	;

index	:	instmnt LPAREN keys RPAREN
	;

instmnt	:	indexq ON NAME IS NAME
	;

indexq	:	INDEX
	;

modify	:	modstmnt alias TO modstorage modkeys modqual
	;

modstmnt:	MODIFY
	;

modstorage:	NAME
	  ;

modkeys :	modstkey modrptkey
	|
	;

modstkey:	ON
	;

modrptkey:	modbasekey
	|	modrptkey COMMA modbasekey
	;

modbasekey:	NAME
	|	NAME COLON NAME
	;

modqual :	modcond modfill
	|
	;

modcond :	WHERE
	;

modfill :	modfillnum
	|	modfill COMMA modfillnum
	;

modfillnum:	NAME IS I2CONST
	|	NAME IS NAME
	;

keys	:	alias
	|	keys COMMA alias
	;

print   :	prinstmnt keys
	;

prinstmnt:	PRINT
	;

save	:	savstmnt alias UNTIL date
	|	savstmnt alias
	;

savstmnt:	SAVE
	;

date	:	month day_year day_year
	;

month	:	alias
	|	day_year
	;

day_year:	I2CONST
	;
%%
