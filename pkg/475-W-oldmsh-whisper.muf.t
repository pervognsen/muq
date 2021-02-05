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

( - 475-W-oldmsh-whisper.muf -- Do player 'whisper'.			)
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
( A: Botulism!								)


( =====================================================================	)
( - Overview --								)


( =====================================================================	)

( - Classes ---								)

( =====================================================================	)
( - cmdWhisper ---							)

defclass: cmdWhisper
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

defmethod:  cmdNames { 'cmdWhisper }
    {[                  'it         ]}

    [ "whisper" "w" |
;


( =====================================================================	)
( - cmdHelpCategory ---							)

( Following only needed if we change the return value to other than ""	)

( defmethod:  cmdHelpCategory { 'cmdWhisper }	)
(    {[                         'it        ]}	)
(    [ "" |                              	)
( ;                                      	)

( =====================================================================	)
( - cmdHelp1 ---							)

( Return a short (less than one line) description of command.		)

defmethod:  cmdHelp1 { 'cmdWhisper }
    {[                   'it         ]}

    [ "Whisper to <someone> in the room <something> private." |
;


( =====================================================================	)
( - cmdHelpN ---							)

( Return a multi-line description of command.  Think of a manpage.	)

defmethod:  cmdHelpN { 'cmdWhisper }
    {[                   'it         ]}

    [
"Whisper something to someone in current room: whisper <who>=<text>
You may abbreviate \"whisper\" to \"w\" if you wish."
    |
;

( =====================================================================	)
( - cmdDo ---								)

( Actually execute command.						)

defmethod: cmdDo { 'cmdWhisper 't  't     }
        |shift -> it
        |shift -> av
        |shift -> cmdName

	'=' charInt |position -> pos
	pos not if "Syntax is 'whisper <whoName>=<text>" errcho ]pop [ | return fi
	0 pos |extract[ ]join -> whoName
	|shiftp


	av.thisRoomCache -> cache
	[ cache whoName oldmud:CAN_HEAR | oldmud:resolveName ]-> who
	who not if
	    "No \"" whoName join "\" listening here" join errcho
	    ]pop
	    [ | return
	fi


	|intChar


	( Do local echo to our own user: )

	'"' |push
	'"' |unshift
	' ' |unshift

	'r' |unshift
	'e' |unshift
	'p' |unshift
	's' |unshift
	'i' |unshift
	'h' |unshift
	'w' |unshift

	' ' |unshift
	'u' |unshift
	'o' |unshift
	'Y' |unshift

	"eko" t @.task.taskState.userIo
	|maybeWriteStreamPacket
	pop pop



	( Now set up message format for recipient: )

	4 |shiftpN

	7 |shiftpN

	',' |unshift
	's' |unshift
	'r' |unshift
	'e' |unshift
	'p' |unshift
	's' |unshift
	'i' |unshift
	'h' |unshift
	'w' |unshift

    ]join -> text

    ( Publish string where recipient can see it: )
( BUGGO, should be locked so -only- recipient can see it )
    [ av text "plain" nil nil | pub:publishString ]-> strId

    ( Tell recipient about the whisper string.	)
    av.thisRoomCache -> cache
    [   :op 'oldmud:REQ_HEAR_WHISPER
	:to who
	:a0 av
	:a1 cache.room
	:a2 strId
	:fa whoName
	:fn :: { [] -> [] }
	    |shift -> whoName		( fa	)
	    |shift -> taskId
	    |shift -> from
	    |shift -> o			( to	)
	    |shift -> av		( a0	)
	    |shift -> room		( a1	)
	    |shift -> strId		( a2	)
	    |shift -> err		( r0	)
	    ]pop

	    ( Ignore success results, announcing every )
	    ( "whisper" receipt would be too tiresome: )
	    err not if
		[ | return
	    fi

	    [ whoName " didn't hear your whisper: " err toString | ]join errcho

	    [ |
	;
    |   ]request


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
