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

( - 402-W-oldavatar-room-cache.muf -- Dynamics.				)
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
( Created:      97Oct10							)
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
( - Package 'oldmud' --							)

"oldmud" inPackage


( =====================================================================	)

( - Functions -								)

( =====================================================================	)

( - Generics -								)

( =====================================================================	)
( - enterRoom -- High-level function to enter a room			)

defgeneric: enterRoom {[ $         $   $     ]} ;
defmethod:  enterRoom { 't         't 't      } ;
defmethod:  enterRoom { 'roomCache 't 't      }
    {[                  'it        'us 'room ]}

    ( Record ourself as enheld ahead of time, to     )
    ( reduce danger of race conditions where someone )
    ( hears we're in the room and asks us if it is   )
    ( true before we ourself have been notified:     )
    us   --> it.us
    us room enheldBy

    ( Inform room that we're entering: )
    [   :op 'oldmud:REQ_ENHOLDING
	:to room
	:a0 us		( Object which is entering )
	:am "enterRoom/REQ_ENHOLDING"
	:fa it
	:fn :: { [] -> [] }
	    |shift -> it		( fa	)
	    |shift -> taskId
	    |shift -> from
	    |shift -> room		( to	)
	    |shift -> us		( a0	)
	    |shift -> err		( r0	)
	    |length 0 != if |shift else 0  fi -> roomCan   ( r1 )
	    |length 0 != if |shift else "" fi -> roomNam   ( r2 )
	    |length 0 != if |shift else "" fi -> roomShort ( r3 )
	    ]pop

	    err if
		nil  --> it.room
                us room deheldBy pop
		err errcho
	    else
		( Mark ourself as not in previous room: )
                us it.room deheldBy pop

		( Inform previous room that we've leaving: )
		it.room if
		    [   :op 'oldmud:REQ_DEHOLDING
			:to it.room
			:a0 it.us	( Object which is leaving )
		    |   ]request

		    ( Inform everyone who cares that we've left: )
		    [ it | allRoomObjects
			( BUGGO:  It would be bad if lots of these requests	)
			( were going to our own daemon, since we're not	)
			( stopping to give it time to process them -- queue	)
			( could easily back up and overflow.  Be better to	)
			( do this as a series of subtasks interleaved with	)
			( input processing, but I'll punt on that for now.	)
			|for o do{
			    ( Notify only objects with CAN_NOTE_ROOM_CONTENTS flag: )
			    [ it o |
				hasRoomObject
				:can 0 |ged -> can
			    ]pop 
			    can CAN_NOTE_ROOM_CONTENTS logand 0 != if
				[   :op 'oldmud:REQ_HAS_LEFT
				    :to o
				    :a0 it.us	( Object which is leaving )
				    :a1 it.room	( Object which been left  )
				|   ]request
			    fi
			}   
		    ]pop
		    nil --> it.room
		fi

		( Clear room cache: )
		[ it | clearRoomCache ]pop

		( Remember new room: )
		us   --> it.us
		room --> it.room
		roomNam   it normalizeName  -> roomNam
		roomShort it normalizeShort -> roomShort
		roomCan integer? not if 0 -> roomCan fi
		roomCan --> it.roomCan
		[   "You enter "   roomNam |
		    roomShort "" != if
			", "       |push
			roomShort |push
		    fi
		    ". "           |push

		    room 	   |push
		    roomCan        |push lookAtCan
		]join echo

		roomShort --> it.roomShort
		roomNam   --> it.roomName

		( Scope out what's in the room: )
		[   :op 'oldmud:REQ_NUMBER_HOLDING
		    :to room
		    :am "enterRoom/REQ_NUMBER_HOLDING"
		    :fa it
		    :fn :: { [] -> [] }
			|shift -> it		( fa	)
			|shift -> taskId
			|shift -> from
			|shift -> room		( to	)
			|shift -> err		( r0	)
			|shift -> n		( r1	)
			]pop
			err if err toString echo   [ | return fi

			( Defend against being spammed by rooms    )
			( that claim to contain a billion objects: )
			n it.maxContents > if
			    it.maxContents -> n
			    "enterRoom: Ignoring all but " n toString join " of contents." join echo
			fi

			( Ask for the skinny on each object: )
			for i from 0 below n do{
			    [   :op 'oldmud:REQ_NTH_HOLDING
				:to room
				:a0 i
				:am "enterRoom/REQ_NTH_HOLDING"
				:fa it
				:fn :: { [] -> [] }
				    |shift -> it	( fa	)
				    |shift -> taskId
				    |shift -> from
				    |shift -> room	( to	)
				    |shift -> i		( a0	)
				    |shift -> err	( r0	)
				    |shift -> o		( r1	)
				    ]pop

				    ( Remember room claims object is present: )
				    err not if
					o it.us != if
				            [ it o |  enterRoomObject ]pop

					    ( Ask object if it thinks it is present: )
					    [   :op 'oldmud:REQ_IS_HELD_BY
						:to o
						:a0 it.room
						:am "enterRoom/REQ_IS_HELD_BY"
						:fa it
						:fn :: { [] -> [] }
						    |shift -> it	( fa	)
						    |shift -> taskId
						    |shift -> from
						    |shift -> o		( to	)
						    |shift -> room	( a0	)
						    |shift -> err	( r0	)
						    |shift -> present	( r1	)
						    |length 0 != if |shift else 0  fi -> can   ( r2 )
						    |length 0 != if |shift else "" fi -> nam   ( r3 )
						    |length 0 != if |shift else "" fi -> short ( r4 )
						    ]pop
						    err if err toString echo [ | return fi

						    ( Remember object admits it is present: )
						    o it.us != if
							present if
							    short it normalizeShort -> short
							    [ it o can nam short from |
								confirmRoomObject
							    ]-> nam

							    ( If object cares, tell it we've )
							    ( arrived, life, can now begin:  )
							    can CAN_NOTE_ROOM_CONTENTS logand 0 != if
								[   :op 'oldmud:REQ_HAS_COME
								    :to o
								    :a0 it.us
								    :a1 it.room
								|   ]request
							    fi

							    [   "In " it.roomName " you see   " nam
							    |
								short "" != if
								    ",   "          |push	
								    short           |push	
								fi
								"."                 |push	

								o can rankText -> rank

								@.task.taskState.showObjectFlags case{
								on: :verbose
								    can canToVerboseText -> s
								    s "" != if
									"   (" |push
									s      |push
									rank   |push
									")"    |push
								    fi	
								on: :compact
								    can canToText -> s
								    s "" != if
									"   (" |push
									s      |push
									rank   |push
									")"    |push
								    fi	
								}
							    ]join echo
						    fi  fi

						    [ |
						;
					    |   ]request
				    fi  fi

				    [ |
				;
			    |   ]request
			}

			[ |
		    ;
		|   ]request
	    fi

	    [ |
        ;
    |   ]request


    [ |
;
'enterRoom export

( =====================================================================	)
( - doReqHasCome -- Handle notification that object A entered B.	)

defmethod:  doReqHasCome { 'roomCache 't  't  't  't  't 't 't   }
    {[                     'me        'it 'hu 'av 'id 'a 'b 'a2 ]}

    ( Ignore unless it potentially affects our cached info: )

    ( Irrelevant if B is not our room: )
    b me.room != if   [ nil | return   fi

    ( Irrelevant if A is already listed as being in B: )
    me.object a getKey? pop if
        [ nil | return
    fi

    ( Check with room: )
    [   :op 'oldmud:REQ_IS_HOLDING
	:to b
	:a0 a
	:fa me
	:fn :: { [] -> [] }
	    |shift -> me	( fa	)
	    |shift -> taskId
	    |shift -> from
	    |shift -> b		( to	)
	    |shift -> a		( a0	)
	    |shift -> err	( r0	)
	    |shift -> present	( r1	)
	    |length 0 != if |shift else 0  fi -> can   ( r2 )
	    |length 0 != if |shift else "" fi -> nam   ( r3 )
	    |length 0 != if |shift else "" fi -> short ( r4 )
	    ]pop

	    ( Ignore erroneous results or ones saying object is absent: )
	    err present not or if   [ | return   fi

	    ( Remember room says object is present: )
	    [ me a |  enterRoomObject ]pop

	    ( Ask object if it thinks it is present: )
	    [   :op 'oldmud:REQ_IS_HELD_BY
		:to a
		:a0 b
		:am "doReqHasCome/REQ_IS_HELD_BY"
		:fa me
		:fn :: { [] -> [] }
		    |shift -> me	( fa	)
		    |shift -> taskId
		    |shift -> from
		    |shift -> a		( to	)
		    |shift -> b		( a0	)
		    |shift -> err	( r0	)
		    |shift -> present	( r1	)
		    |length 0 != if |shift else 0  fi -> can   ( r2 )
		    |length 0 != if |shift else "" fi -> nam   ( r3 )
		    |length 0 != if |shift else "" fi -> short ( r4 )
		    ]pop

		    err if err toString echo [ | return fi

		    ( Remember object admits it is present: )
		    a me.us != if
			present if
			    short me normalizeShort -> short
			    [ me a can nam short from | confirmRoomObject ]-> nam
			    [   "* " nam " has arrived in " me.roomName "."
			    |
				short "" != if
				    "  "            |push	
				    nam             |push	
				    " is "          |push	
				    short           |push	
				    "."             |push	
				fi
				a can rankText -> rank
				@.task.taskState.showObjectFlags case{
				on: :verbose
				    can canToVerboseText -> s
				    s "" != if
					"  ("  |push
					s      |push
					rank   |push
					")"    |push
				    fi	
				on: :compact
				    can canToText -> s
				    s "" != if
					"  ("  |push
					s      |push
					rank   |push
					")"    |push
				    fi	
				}
			    ]join echo
		    fi  fi

		    [ |
		;
	    |   ]request

	    [ |
	;
    |   ]request

    [ nil |
;

( =====================================================================	)
( - doReqHasLeft -- Handle notification that an object A has left B.	)

defmethod:  doReqHasLeft { 'roomCache 't  't  't  't  't 't 't   }
    {[                     'me        'it 'hu 'av 'id 'a 'b 'a2 ]}

    ( Ignore unless it potentially affects our cached info: )

    ( Irrelevant if B is not our room: )
    b me.room != if   [ nil | return   fi

    ( Irrelevant if A is not listed as being in B: )
    [ me a | hasRoomObject ]-> inB
    inB not if   [ nil | return   fi

    ( Check with object: )
    [   :op 'oldmud:REQ_IS_HELD_BY
	:to a
	:a0 b
	:am "doReqHasLeft/REQ_IS_HELD_BY"
	:fa me
	:fn :: { [] -> [] }
	    |shift -> me	( fa	)
	    |shift -> taskId
	    |shift -> from
	    |shift -> a		( to	)
	    |shift -> b		( a0	)
	    |shift -> err	( r0	)
	    |shift -> present	( r1	)
	    |length 0 != if |shift else 0  fi -> can   ( r2 )
	    |length 0 != if |shift else "" fi -> nam   ( r3 )
	    |length 0 != if |shift else "" fi -> short ( r4 )
	    ]pop

	    ( Ignore erroneous results or ones saying object is present; )
	    err present or if   [ | return   fi

	    ( Get name of object: )
	    [ me a | roomObjectInfo
		:name nil |ged -> aNam
	    ]pop

	    nam if
		[ "* " nam " has left " me.roomName "." | ]join echo
	    fi
		
	    ( Forget object is present: )
	    [ me a |  forgetRoomObject ]pop

	    [ |
	;
    |   ]request

    [ nil |
;

( =====================================================================	)
( - doReqHasBeenEjected -- Notification that A has been ejected from B.	)

defmethod:  doReqHasBeenEjected { 'roomCache 't  't  't  't  't 't 't   }
    {[                            'me        'it 'hu 'av 'id 'a 'b 'a2 ]}

    ( Ignore unless it potentially affects our cached info: )

"doReqHasBeenEjected called...\n" log,
    ( Irrelevant if B is not our room: )
    b me.room != if   [ nil | return   fi

    ( Irrelevant if A is not listed as being in B: )
    [ me a | hasRoomObject ]-> inB
    inB not if   [ nil | return   fi

    ( ------------------------------------------------ )
    ( BUGGO, should check that notification is from B! )
    ( ------------------------------------------------ )

    ( Forget object is present: )
    [ me a |  forgetRoomObject ]pop

    [ nil |
;

( =====================================================================	)
( - updateShortDescInRoomCache -- Update cache for changed description.	)

:   updateShortDescInRoomCache { $ $ -> }
    -> newDesc
    -> obj

    @.task.taskState.thisRoomCache -> it

    ( Room itself is a special case: )
    obj it.room = if
        newDesc --> it.roomShort
	return
    fi

    ( Ignore if we don't have object: )
    it.object   obj  getKey? -> i not if return fi

    ( Update short description in cache record: )
    newDesc --> it.short[i]
;
'updateShortDescInRoomCache export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

