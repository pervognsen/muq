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

( - 400-W-oldroom.muf -- Rooms for rooms-and-exits islekit.		)
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

( --------------------------------------------------------------------- )
(									)
(	For Mike Jittlov: A wiz of a wiz if ever there was!		)
(									)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      97Oct11, from 400-W-oldexit.t				)
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
( ---------------------------------------------------------------------	)

( =====================================================================	)
( - Package 'oldmud', exported symbols --				)

"oldmud" inPackage





( =====================================================================	)

( - Functions -								)

( =====================================================================	)
( - enterDefaultRoomHandlers -- Convenience fn.				)

:   enterDefaultRoomHandlers { $ $ $ -> }
    -> c
    -> f
    -> n

    n f c enterDefaultThingHandlers
    n f c enterCanonicalRoomNameServerFunctions
;
'enterDefaultThingHandlers export

( =====================================================================	)

( - Private static variables						)

'_roomOpNames   not bound? if makeStack --> _roomOpNames   fi
'_roomOpFns     not bound? if makeStack --> _roomOpFns     fi
'_roomOpClasses not bound? if makeStack --> _roomOpClasses fi

_roomOpNames   reset
_roomOpFns     reset
_roomOpClasses reset

_roomOpNames _roomOpFns _roomOpClasses enterDefaultRoomHandlers


( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - room -- Primary location for avatars to be.				)

defclass: room
    :export t
    :isA 'thing

    :slot :canonicalName   :prot "rw----"   :initval ""
;


( =====================================================================	)

( - Public class creation functions -					)

( =====================================================================	)
( - initRoom -- 							)

:   initRoom { [] -> [] }
    |shift -> room
    |shift -> name
    |shift -> short
    |shift -> home
    ]pop

    name  --> room.name
    short --> room.short

    CAN_ENTER -> can
    room.viewExteriorText room.viewInteriorText or if can CAN_TEXT_VIEW + -> can fi
    room.viewExteriorHtml room.viewInteriorHtml or if can CAN_HTML_VIEW + -> can fi
    room.viewExteriorVrml room.viewInteriorVrml or if can CAN_VRML_VIEW + -> can fi
    can --> room.can

    ( Rooms don't have individual daemons, )
    ( they use HOME's daemon and io:       )
    home.io --> room.io
    home    --> room.liveDaemon

    ( Define commands implemented by room daemon: )
    _roomOpNames   --> room.liveNames
    _roomOpFns     --> room.liveFns
    _roomOpClasses --> room.liveClasses

    [ room |
;
'initRoom export


( =====================================================================	)
( - makeRoom -- 							)

defgeneric: makeRoom {[ $     $      $           ]} ;
defmethod:  makeRoom { 't    't     't            } ;
defmethod:  makeRoom { 't    't     'daemonHome  }
    {[                  'name 'short 'home        ]}

    name isAString

    'room makeInstance -> room

    [ room name short home | initRoom
;
'makeRoom export


( =====================================================================	)

( - Generic functions -							)

( =====================================================================	)
( - doReqCanonicalRoomName -- Get canonical name for room.		)

defmethod:  doReqCanonicalRoomName { 'room 't  't  't  't  't  't  't   }
    {[                                   'me   'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    ( Return canonical name for room.  This consists of )
    ( a daemon plus a string which that daemon maps to  )
    ( a hard room pointer, via REQ_ROOM_BY_NAME:        )
    nil                           -> err
    ( This isn't pretty, but:  We want to find the isle  )
    ( daemon, right now if me.liveDaemon isn't our isle )
    ( daemon, then it is an avatar daemon:               )
    me.liveDaemon -> daemon
    daemon isle? not if  daemon.homeRoom.liveDaemon -> daemon fi
    me.name                       -> name
    [ err daemon name |
;


( =====================================================================	)
( - findLocalExitNamed -- Support fn for inventRoom.			)

:   findLocalExitNamed { [] -> [] }
    |shift -> me	( room 		)
    |shift -> exitName	( string	)
    ]pop

    [ me | numberHolding ]-> n

    for i from 0 below n do{
	[ me i | nthHolding
	    |shift -> err
	    |shift -> h
	]pop
	err not if
	    h remote? not if
		h.name exitName =-ci if [ h | return fi
	fi  fi
    }

    [ nil |
;

( =====================================================================	)
( - inventRoom -- Invent a missing room, given room and exitName.	)

defmethod:  inventRoom { 'room  't         }
    {[                   'me    'exitName ]}

    [ me exitName | findLocalExitNamed ]-> exit
    exit if
	[ exit me exitName | inventRoomViaExit return
    fi

    [ t nil |
;

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

