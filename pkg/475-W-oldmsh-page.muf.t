@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)
@example  @c

( - 475-W-oldmsh-page.muf -- Do player 'page'.				)
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
(	For Mike Jittlov: A wiz of a wiz if ever there was!		)
(									)
(  -------------------------------------------------------------------  )

(  -------------------------------------------------------------------  )
( Author:       Jeff Prothero						)
( Created:      97Oct25							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1998, by Jeff Prothero.				)
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
(  ------------------------------------------------------------------- 	)

( =====================================================================	)
( - Package 'msh', exported symbols --					)

"oldmsh" inPackage

( =====================================================================	)
( - Quip --								)

( Q: What do you call a plague of 'bots?				)
( A: Bot-ulism!								)


( =====================================================================	)
( - Overview --								)


( =====================================================================	)

( - Classes ---								)

( =====================================================================	)
( - cmdPage ---							)

defclass: cmdPage
    :export t
    :isA 'mshCommand
;

( =====================================================================	)

( - Methods ---								)

( =====================================================================	)
( - cmdNames ---							)

( Return the list of names by which the user can invoke command.	)
( Full/normal names should be first, nicknames and abbrevs later.	)
( One name is sufficient for most commands.				)

defmethod:  cmdNames { 'cmdPage }
    {[                  'it      ]}

    [ "page" "pa" |
;


( =====================================================================	)
( - cmdHelpCategory ---							)

( Following only needed if we change the return value to other than ""	)

( defmethod:  cmdHelpCategory { 'cmdPage }	)
(    {[                         'it     ]}	)
(    [ "" |                              	)
( ;                                      	)

( =====================================================================	)
( - cmdHelp1 ---							)

( Return a short (less than one line) description of command.		)

defmethod:  cmdHelp1 { 'cmdPage }
    {[                   'it      ]}

    [ "Page to <someone> <sometext>." |
;


( =====================================================================	)
( - cmdHelpN ---							)

( Return a multi-line description of command.  Think of a manpage.	)

defmethod:  cmdHelpN { 'cmdPage }
    {[                   'it      ]}

    [
"Page something to someone: page <who>=<text>
You may abbreviate \"page\" to \"pa\" if you wish."
    |
;

( =====================================================================	)
( - sweepStack --- Collect values on stack into a string and return it	)

:   sweepStack  { -> $ ! }   ( Lie outrageously about arity. )
    "" -> result
    do{ depth 0 = until
	block? if
	    do{ |length 0 = until
		|shift toString result " " join swap join -> result
	    }
	    ]pop
	    loopNext
	fi
        toString result " " join swap join -> result
    }

    ( Strip leading blank: )
    result length 0 > if
	result 1 result length substring -> result
    fi

    result
;

( =====================================================================	)

( - expandBackquotes --- '...`printf("Hello, %s","world")`...'	&tc	)

:   expandBackquotes { $ $ $ -> $ }
    -> bq2
    -> bq1
    -> str

    str length -> len

    str   0         bq1   substring   -> prefix
    str   bq1 1 +   bq2   substring   -> infix
    str   bq2 1 +   len   substring   -> suffix

    "^" infix join   muc:evalString

    sweepStack -> newinfix

    [ prefix newinfix suffix | ]join -> result

    result
;

( =====================================================================	)

( - |doBackquotes ---							)

:   |doBackquotes { [] -> [] }

    nil -> bq1
    |for c i do{
        c '`' = if
            bq1 not if
                i -> bq1
	    else
		]join bq1 i expandBackquotes vals[
		'|doBackquotes call{ [] -> [] }
		return
            fi
        fi
    }
;


( =====================================================================	)
( - cmdDo ---								)

( Actually execute command.						)

defmethod: cmdDo { 'cmdPage 't  't     }
        |shift -> it
        |shift -> av
        |shift -> cmdName

	'=' charInt |position -> pos
	pos not if "Syntax is 'page <whoName>=<text>" errcho ]pop [ | return fi
	0 pos |extract[ ]join -> globalName
	|shiftp

	|intChar

	|doBackquotes


	( Do local echo to our own user: )

	'"' |push
	'"' |unshift
	' ' |unshift

	'e' |unshift
	'g' |unshift
	'a' |unshift
	'p' |unshift

	' ' |unshift
	'u' |unshift
	'o' |unshift
	'Y' |unshift

	"eko" t @.task.taskState.userIo
	|maybeWriteStreamPacket
	pop pop



	( Now set up message format for other user: )

	4 |shiftpN

	4 |shiftpN

	',' |unshift
	's' |unshift
	'e' |unshift
	'g' |unshift
	'a' |unshift
	'p' |unshift

    ]join -> text

    ( Convert avatar name into avatar pointer: )
    [   :isle av.homeIsle
        :name globalName
        :fa [ av text globalName | ]vec
	:fn ::
	    |shift -> fa
	    |shift -> err
	    |shift -> who	( Avatar to send page to )
	    ]pop
	    fa[0] -> av
	    fa[1] -> text
	    fa[2] -> globalName

	    ( Check for attempt to page non-existent avatar: )
	    err   who not   or if
		"No \"" globalName join "\" found" join errcho
		[ | return
	    fi

	    ( Publish string where folks can see it: )
	    [ av text "plain" nil nil | pub:publishString ]-> strId

	    ( Tell recipient about the page string: )
	    av.thisRoomCache -> cache
	    [   :op 'oldmud:REQ_HEAR_PAGE
		:to who
		:a0 av
		:a1 strId
		:a2 av.homeIsle
		:fa globalName
		:fn :: { [] -> [] }
		    |shift -> globalName	( fa	)
		    |shift -> taskId
		    |shift -> from
		    |shift -> who		( to	)
		    |shift -> av		( a0	)
		    |shift -> strId		( a1	)
		    |shift -> homeIsle		( a2	)
		    |shift -> err		( r0	)
		    ]pop

		    ( Ignore success results, announcing every )
		    ( "page" receipt would be too tiresome:    )
		    err not if   [ | return   fi

		    [ globalName " didn't hear your page: " err toString | ]join errcho

		    [ |
		;
	    |   ]request

	    [ |
	;
    |   oldmud:globalNameToAvatar ]pop

    [ |
;


( =====================================================================	)

( - Vanilla functions ---						)

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
