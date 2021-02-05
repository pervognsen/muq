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

( - 475-W-oldmsh-repeat.muf -- Command for mudUser shell package.	)
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
( Created:      97Aug13, from 475-W-oldmsh-ping-self.t			)
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
( - Quote								)
(									)
(	"Common sense is what tells you the world is flat."		)
(									)
(  ------------------------------------------------------------------- 	)


( =====================================================================	)
( - Package 'msh', exported symbols --					)

"oldmsh" inPackage

( =====================================================================	)
( - Overview --								)


( =====================================================================	)

( - Classes ---								)

( =====================================================================	)
( - cmdRepeat ---							)

defclass: cmdRepeat
    :export t
    :isA 'mshCommand
;

( =====================================================================	)

( - Vanilla functions ---						)

( =====================================================================	)

( - |eatWhitespace -- Drop all leading whitespace from stackblock	)

:   |eatWhitespace { [] -> [] }
    do{
        |length 0 = if return fi
        0 |dupNth whitespace? not if return fi
	|shiftp
    }
;


( =====================================================================	)

( - |getInteger -- Scan (and delete) leading integer in stackblock	)

:   |getInteger { [] $ -> [] $ }
    -> result	( Default result if no integer found.			)
    |length 0 = if            result return fi
    |first digitChar? not if result return fi
    0 -> result
    '0' charInt -> zero
    do{
	|shift charInt zero -    result 10 *  +   -> result
        |length 0 = if            result return fi
        |first digitChar? not if result return fi
    }
;


( =====================================================================	)

( - Methods ---								)

( =====================================================================	)

( - cmdNames ---							)

( Return the list of names by which the user can invoke command.	)
( Full/normal names should be first, nicknames and abbrevs later.	)
( One name is sufficient for most commands.				)

defmethod:  cmdNames { 'cmdRepeat }
    {[                  'it        ]}

    [ "@repeat" |
;


( =====================================================================	)
( - cmdHelpCategory ---							)

( Following only needed if we change the return value to other than ""	)

( defmethod:  cmdHelpCategory { 'cmdRepeat }	)
(    {[                         'it       ]}	)
(    [ "" |                              	)
( ;                                      	)

( =====================================================================	)

( - cmdHelp1 ---							)

( Return a short (less than one line) description of command.		)

defmethod:  cmdHelp1 { 'cmdRepeat }
    {[                   'it        ]}

    [ "Do <repeats> echos at <delay> secs of <text>." |
;


( =====================================================================	)

( - cmdHelpN ---							)

( Return a multi-line description of command.  Think of a manpage.	)

defmethod:  cmdHelpN { 'cmdRepeat }
    {[                   'it        ]}

    [
"Echos text repeatedly, as a test of the delayedExecution facilities.
All arguments are optional."
    |
;

( =====================================================================	)

( - ourEchoFn ---							)

:   ourEchoFn { [] -> [] }
    |shift -> taskId
    |shift -> repeats
    |shift -> delay
    |shift -> av
    |shift -> msg
    ]pop    

    msg echo

    -- repeats

    repeats 0 > if
	( Schedule another repeat of us to execute: )
        [ av.daemonTask delay taskId nil 'ourEchoFn repeats delay av msg | task:inDo ]pop
        [ av | oldmud:doNop ]pop
    fi

    [ |
;


( =====================================================================	)

( - cmdDo ---								)

( Actually execute command.						)

defmethod: cmdDo { 'cmdRepeat 't  't     }
    |shift -> it
    |shift -> av
    |shift -> name

    |length -> len
    |intChar
    |deleteNonchars

    ( Parse repeat count: )
    |eatWhitespace   1 |getInteger -> repeatCount

    ( Parse delay time: )
    |eatWhitespace   1 |getInteger -> delayTime

    ( Rest become message to echo repeatedly: )
    |eatWhitespace
    ]join -> msg
    msg "" = if "Testing..." -> msg fi

    ( Submit jobs to the delayedExecution queue: )
    [ av.daemonTask delayTime nil nil 'ourEchoFn repeatCount delayTime av msg | task:inDo ]pop

    ( Send a NOP to wake the daemon so it will schedule above: )
    [ av | oldmud:doNop ]pop

    [ |
;


( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
