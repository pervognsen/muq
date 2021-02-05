@c - This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)
@example  @c

( - 211-C-muc-compiler.muf -- Code generation for Multi-User-C.		)
( - This file is formatted for outline-minor-mode in emacs19.		)
( -^C^O^A shows All of file.						)
(  ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)	)
(  ^C^O^T hides all Text. (Leaves all headings.)			)
(  ^C^O^I shows Immediate children of node.				)
(  ^C^O^S Shows all of a node.						)
(  ^C^O^D hiDes all of a node.						)
(  ^HFoutline-mode gives more details.					)
(  (Or do ^HI and read emacs:outline mode.)				)

( =====================================================================	)
( - Dedication and Copyright.						)

(  -------------------------------------------------------------------  )
(									)
(		For Firiss:  Aefrit, a friend.				)
(									)
(  -------------------------------------------------------------------  )

(  -------------------------------------------------------------------  )
( Author:       Jeff Prothero						)
( Created:      99Sep19							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 2000, by Jeff Prothero.				)
( 									)
(  This program is free software; you may use, distribute and/or modify	)
(  it under the terms of the GNU Library General Public License as      )
(  published by	the Free Software Foundation; either version 2, or at   )
(  your option	any later version FOR NONCOMMERCIAL PURPOSES.		)
(									)
(  COMMERCIAL operation allowable at $100/CPU/YEAR.			)
(  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.		)
(  Other commercial arrangements NEGOTIABLE.				)
(  Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.			)
( 									)
(    This program is distributed in the hope that it will be useful,	)
(    but WITHOUT ANY WARRANTY; without even the implied warranty of	)
(    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	)
(    GNU Library General Public License for more details.		)
( 									)
(    You should have received a copy of the GNU General Public License	)
(    along with this program: COPYING.LIB; if not, write to:		)
(       Free Software Foundation, Inc.					)
(       675 Mass Ave, Cambridge, MA 02139, USA.				)
( 									)
( Jeff Prothero DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	)
( INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN	)
( NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR	)
( CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	)
( OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		)
( NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	)
( WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.				)
( 									)
( Please send bug reports/fixes etc to bugs@@muq.org.			)
(  -------------------------------------------------------------------	)

( =====================================================================	)
( - Quote			             				)

(	"To teach superstitions as truth is a most terrible thing."	)
(					-- Hypatia of Alexandria	)
(									)
(		(Naturally, the mob skinned her alive.)			)
(		http://antwrp.gsfc.nasa.gov/apod/ap990127.html		)


( =====================================================================	)
( - Package			             				)

"MUC" rootValidateDbfile pop
[ "muc" .db["MUC"] | ]inPackage

( =====================================================================	)
( - compileFile -- Simple muc file compiler.				)

:   compileFile { -> ? }

    ( Get stream to read from: )
    @.standardInput -> mss
    mss isAMessageStream

    [   :ephemeral t
        :mss       mss
        :package   .lib["muf"]
        :outermost t
    | 'compile:context ]makeStructure -> ctx

    makeFunction -> fun


    (      -- BEGIN BOILERPLATE --        )

    ( Establish a restart letting users   )
    ( to kill the job from the debugger:  )
    [   :function :: { -> ! } nil endJob ;
        :name 'endJob
        :reportFunction "Terminate job."
    | ]withRestartDo{               ( 1 )

    ( Establish a handler letting users   )
    ( terminate a job with a signal       )
    ( -- via 'killJob' say:              )
    [ .e.kill :: { [] -> [] ! } :why |get endJob ;
    | ]withHandlerDo{               ( 2 )

    ( Establish a restart letting users   )
    ( return to the main shell prompt     )
    ( from the debugger:                  )
    [   :function :: { -> ! }  'abrt goto ;
	:name 'abort
	:reportFunction "Return to main mufShell prompt."
    | ]withRestartDo{               ( 3 )

    ( Establish a handler letting users   )
    ( abort a job with a signal           )
    ( -- via 'abortJob' say:             )
    [ .e.abort :: { [] -> [] ! } 'abort invokeRestart ;
    | ]withHandlerDo{               ( 4 )

    withTag abrt do{       ( 8 ) ( Trap compile errs etc    )
    abrt                          ( Continuation from errors )
    (       -- END BOILERPLATE --         )


    ( Establish handler to report errors: )
    [ .e.error ( simpleError or serverError, presumably )
      ']reportCompileError
    | ]withHandlersDo{              ( 5 )


    makeStack --> @.yyss    ( State stack -- central data structure.   )
    makeStack --> @.yyvs    ( Value stack, parallel to state stack.    )
    nil       --> @.yyval   ( ACTIONS put rule value in this variable. )
    nil       --> @.yylval  ( LEXER puts token value in this variable. )
    nil       --> @.yydebug ( Set true for vebose logging of parsing.  )

    'readMucInputLine --> @.yyreadfn
    nil               --> @.yyprompt

    ( Buggo, should really save and restore byacc state: )
    _yylhs           --> @.yylhs
    _yylen           --> @.yylen
    _yydefred        --> @.yydefred
    _yydgoto         --> @.yydgoto
    _yysindex        --> @.yysindex
    _yyrindex        --> @.yyrindex
    _yygindex        --> @.yygindex
     YYTABLESIZE     --> @.YYTABLESIZE
    _yytable         --> @.yytable
    _yycheck         --> @.yycheck
     YYFINAL         --> @.YYFINAL
     YYMAXTOKEN      --> @.YYMAXTOKEN
    _yyname          --> @.yyname
    _yyrule          --> @.yyrule
    _yyaction        --> @.yyaction

    ( Central readEvalPrint loop: )
    do{
	( Save compile context where )
        ( user code &tc can find it: )
	ctx --> @.compiler

	( Reset assembler for new function: )
        [ ctx | compile:resetContext ]pop

        0                 --> @.yycursor
	readMucInputLine  --> @.yyinput

	yyparse pop
    }

    } ( 8 )
    } ( 5 )
    } ( 4 )
    } ( 3 )
    } ( 2 )
    } ( 1 )
;
'compileFile    export

'compileMucFile export
#'compileFile --> #'compileMucFile




( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

@c
@node Muc Compiler Wrapup, Function Index, Muc Compiler Source, Muc Compiler
@section Muc Compiler Wrapup

This completes the in-db @sc{muc}-compiler chapter.  If you have
questions or suggestions, feel free to email cynbe@@mug.org.
