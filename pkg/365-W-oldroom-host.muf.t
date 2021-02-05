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

( - 370-W-oldroom-host.muf -- Roomhosts for rooms-and-exits islekit.	)
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
( Created:      97Oct23, from 370-W-oldisle.t				)
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
( - Package 'oldmud', forward declarations --				)

"oldmud" inPackage



( =====================================================================	)

( - Functions -								)


( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - roomHost -- index of rooms						)

( A roomHost knows how to resolve canonical room names to		)
( actual room pointers.	 It supports ephemeral rooms, which		)
( are procedurally defined and created only at time of entry.		)

defclass: roomHost
    :export t
    :isA 'daemonHome

    :slot :room        :prot "rw----"  :initform :: makeHash   ;
    :slot :roomLock    :prot "rw----"  :initform :: makeLock   ; 
;







( =====================================================================	)

( =====================================================================	)

( - Public class creation functions -					)

( =====================================================================	)
( - enterDefaultRoomHostHandlers -- 				)

:   enterDefaultRoomHostHandlers { $ $ $ -> }
    -> c
    -> f
    -> n

    REQ_ROOM_BY_NAME 'doReqRoomByName nil   n f c enterOp
;
'enterDefaultRoomHostHandlers export

( =====================================================================	)
( - inventRoom -- Invent a missing room, given room + exitName in it.	)

defgeneric: inventRoom {[ $      $    ]} ;
defmethod:  inventRoom { 't     't     } ]pop [ t nil | ;
'inventRoom export

( =====================================================================	)
( - inventRoomViaExit -- Invent missing room, given room exit in it.	)

defgeneric: inventRoomViaExit {[ $  $  $ ]} ;
defmethod:  inventRoomViaExit { 't 't 't  } ]pop [ t nil | ;
'inventRoomViaExit export

( =====================================================================	)
( - noteRoom -- Enter room into list of existing rooms.		)

defgeneric: noteRoom {[ $          $         $         ]} ;
defmethod:  noteRoom { 't         't        't          } "noteRoom" gripe ;
defmethod:  noteRoom { 'roomHost 't        't          }
    {[                  'me        'newRoom 'roomName ]}

    ( Sanity checks: )
    roomName isAString
    roomName ";" findSubstring? pop pop if
        [ "May not use ';' in room name" nil nil | return
    fi

    asMeDo{

	me.roomLock withLockDo{
	    ( Make room name unique: )
	    roomName -> n
	    1         -> j
	    do{ me.room n get? pop while
		++ j
		roomName "#" j toString join join -> n
	    }
	    n -> roomName

	    ( Enter room into index: )
	    newRoom --> me.room[roomName]

	    [ nil newRoom roomName |
	}
    }

;
'noteRoom export


( =====================================================================	)
( - findRoom -- Find/create room given canonical name.			)

defgeneric: findRoom {[ $          $    ]} ;
defmethod:  findRoom { 't         't     } "findRoom" gripe ;
defmethod:  findRoom { 'roomHost 't     }
    {[                  'me        'name ]}

    name isAString

    ( In the simplest case, room exists: )
    me.room name get? -> room if [ nil room | return fi

    name ";" findSubstring? pop pop not if
        [ "Can't find a room '" name join "'" join nil | return
    fi

    ( Explode string into semicolon-separated parts: )
    name ";" chopString[

	( We'd better have at least two parts: )
        |length 2 < if ]pop [ t nil | return fi

	( First part must name an existing room: )
        |shift -> path
	me.room path get? -> thisRoom not if ]pop [ t nil | return fi

	( Step along path from base room, creating next room in tree: )
	|for n do{
	    [ thisRoom n | inventRoom
		|shift -> err
		|shift -> thisRoom
	    ]pop
	    err if ]pop [ err nil | return fi	( Couldn't invent it )
	}
    ]pop

    [ nil thisRoom |
;
'findRoom export


( =====================================================================	)
( - doReqRoomByName -- Find a room.					)

defgeneric: doReqRoomByName {[ $          $   $   $   $   $     $   $  ]} ;
defmethod:  doReqRoomByName { 't         't  't  't  't  't    't  't   } "doReqRoomByName" gripe ;
defmethod:  doReqRoomByName { 'roomHost 't  't  't  't  't    't  't   }
    {[                            'me        'it 'hu 'av 'id 'name 'a1 'a2 ]}

    [ me name | findRoom
        |shift -> err
    ]-> room

    [ err room |
;
'doReqRoomByName export


( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

