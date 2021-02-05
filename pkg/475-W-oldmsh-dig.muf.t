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

( - 475-W-oldmsh-dig.muf -- Command for mudUser shell package.		)
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
( Created:      97Oct23, from 475-W-oldmsh-go.t				)
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
( - Quip --								)

( The expert hacker knows how to write most any kind of code.		)
( The master hacker knows enough not to. :)				)

( =====================================================================	)
( - Package 'msh', exported symbols --					)

"oldmsh" inPackage

( =====================================================================	)
( - Overview --								)


( =====================================================================	)

( - Classes ---								)

( =====================================================================	)
( - cmdDig ---								)

defclass: cmdDig
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

defmethod:  cmdNames { 'cmdDig  }
    {[                  'it       ]}

    [ "@dig" |
;


( =====================================================================	)
( - cmdHelpCategory ---							)

( Following only needed if we change the return value to other than ""	)

( defmethod:  cmdHelpCategory { 'cmdDig }	)
(    {[                         'it    ]}	)
(    [ "" |                              	)
( ;                                      	)

( =====================================================================	)
( - cmdHelp1 ---							)

( Return a short (less than one line) description of command.		)

defmethod:  cmdHelp1 { 'cmdDig }
    {[                 'it    ]}

    [ "Dig exits <to> and <from> a new <room>." |
;


( =====================================================================	)
( - cmdHelpN ---							)

( Return a multi-line description of command.  Think of a manpage.	)

defmethod:  cmdHelpN { 'cmdDig }
    {[                   'it      ]}

    [
"Create a new room: @dig <hereExitName>=<backExitName>=<roomName>."
    |
;

( =====================================================================	)
( - notifyEveryoneInRoomOfExitArrival ---				)

:   notifyEveryoneInRoomOfExitArrival { [] -> [] }
    |shift -> hereToNewRoom
    ]pop

    ( Update our room cache with presence of exit: )
    @.task.taskState.thisRoomCache -> it 
    [   :op 'oldmud:REQ_HAS_COME
	:to @.task.taskState
	:a0 hereToNewRoom	( Object which is appearing	)
	:a1 it.room		( Room in which object appeared	)
    |   ]request

    ( Inform everyone who cares that exit has appeared: )
    [ it | oldmud:allRoomObjects
	( BUGGO:  It would be bad if lots of these requests	)
	( were going to our own daemon, since we're not	)
	( stopping to give it time to process them -- queue	)
	( could easily back up and overflow.  Be better to	)
	( do this as a series of subtasks interleaved with	)
	( input processing, but I'll punt on that for now.	)
	|for o do{
	    ( Notify only objects with CAN_NOTE_ROOM_CONTENTS flag: )
	    [ it o |
		oldmud:hasRoomObject
		:can 0 |ged -> can
	    ]pop 
	    can oldmud:CAN_NOTE_ROOM_CONTENTS logand 0 != if
		[   :op 'oldmud:REQ_HAS_COME
		    :to o
		    :a0 hereToNewRoom	( Object which is appearing	)
		    :a1 it.room		( Room in which object appeared	)
		|   ]request
	    fi
	}   
    ]pop

    [ |
;

( =====================================================================	)
( - cmdDo ---								)

( Actually execute command.						)

defmethod: cmdDo { 'cmdDig 't  't     }
(    {[             'it      'av 'name ]} )
        |shift -> it
        |shift -> av
        |shift -> name

	'=' charInt |position -> pos
	pos not if "Syntax is '@dig <exitName>=<backExitName>=<roomName>" errcho ]pop [ | return fi
	0 pos |extract[ ]join -> exitName
	|shiftp

	'=' charInt |position -> pos
	pos not if "Syntax is '@dig <exitName>=<backExitName>=<roomName>" errcho ]pop [ | return fi
	0 pos |extract[ ]join -> backExitName
	|shiftp
    ]join -> roomName

    av.thisRoomCache -> cache
    cache.room         -> here
    cache.roomCan     -> roomCan

    roomCan oldmud:CAN_LINK logand 0 = if

	( If room is remote, we know we don't own it without )
        ( bothering to pay a network roundTrip:             )
        here remote? if
	    "Can't @dig unless room is dig-ok or you own it" errcho
	    [ | return
        fi    

	here$s.owner @.owner != if
	    "Can't @dig unless room is dig-ok or you own it" errcho
	    [ | return
	fi

	t                            -> weOwnHere
    else
        here remote? if
	    nil                      -> weOwnHere
	else
	    here$s.owner @.owner = -> weOwnHere
	fi
    fi    

    [   :op 'oldmud:REQ_CANONICAL_ROOM_NAME
	:to here		( Room to get canonical name for.	)
	:am "cmdDig/REQ_CANONICAL_ROOM_NAME"
	:fa  [ av roomName exitName backExitName weOwnHere | ]vec
	:fn :: { [] -> [] }
	    |shift -> fa		( fa	)
	    |shift -> taskId
	    |shift -> from
	    |shift -> here		( to	)
	    |shift -> err		( r0	)
	    |shift -> daemon		( r1	)
	    |shift -> canonicalRoomName	( r2	)
	    ]pop
	    fa[0] -> av
	    fa[1] -> roomName
	    fa[2] -> exitName
	    fa[3] -> backExitName
	    fa[4] -> weOwnHere

	    av.thisRoomCache -> cache
	    cache.room         -> here

	    ( Create the new room: )
	    [ roomName nil av | oldmud:makeRoom ]-> newRoom

	    ( Note new room in isleWide db: )
	    [ av.homeIsle newRoom roomName | oldmud:noteRoom
		|shift -> err
		|shift -> newRoom
		|shift -> roomName	( roomName is now canonicalized... )
	    ]pop

	    ( Note new room in our personal db: )
	    newRoom --> av.room[roomName]

	    ( Note possibly new room name in it.  )
	    ( This is needed so we can return the )
	    ( correct canonical name to exits as  )
	    ( they are built, so crossworld exits )
	    ( will work correctly:                )
	    roomName --> newRoom.name

	    ( Create exitPair joining here and newRoom: )

	    [ backExitName nil av | oldmud:makeExit ]-> newRoomToHere
	    [ exitName      nil av | oldmud:makeExit ]-> hereToNewRoom

	    newRoomToHere --> hereToNewRoom.exitTwin
	    hereToNewRoom --> newRoomToHere.exitTwin

	    roomName            --> hereToNewRoom.exitDestination
	    canonicalRoomName  --> newRoomToHere.exitDestination
	    daemon               --> newRoomToHere.exitDaemon

	    newRoom         newRoomToHere oldmud:enhold
	    newRoomToHere newRoom         oldmud:enheldBy

	    hereToNewRoom here oldmud:enheldBy

	    weOwnHere if

		( Skip the daemon protocol stuff: )
		here hereToNewRoom oldmud:enhold

		[ hereToNewRoom | notifyEveryoneInRoomOfExitArrival ]pop

		"* @dig done *" echo
	    else
		( Deposit hereToNewRoom exit in room here: )
		[   :op 'oldmud:REQ_ENHOLDING
		    :to here			( Room to do the holding.	)
		    :a0 hereToNewRoom	( Object for room to hold.	 )
		    :am "cmdDig/REQ_ENHOLDING"
		    :fa newRoom
		    :fn :: { [] -> [] }
			|shift -> newRoom		( fa	)
			|shift -> taskId
			|shift -> from
			|shift -> here			( to	)
			|shift -> hereToNewRoom	( a0	)
			|shift -> err			( r0	)
			]pop

			[ hereToNewRoom | notifyEveryoneInRoomOfExitArrival ]pop

			err if err errcho [ | return fi

			"* @dig complete *" echo

			[ |
		    ;
		|   ]request
	    fi

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
