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

( - 475-W-oldmsh-look.muf -- Command for mudUser shell package.	)
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
( Created:      97Oct05, from 475-W-oldmsh-view-self.t			)
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
( - Overview --								)


( =====================================================================	)

( - Classes ---								)

( =====================================================================	)
( - cmdLook ---								)

defclass: cmdLook
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

defmethod:  cmdNames { 'cmdLook  }
    {[                  'it       ]}

    [ "look" "l" |
;


( =====================================================================	)
( - cmdHelpCategory ---							)

( Following only needed if we change the return value to other than ""	)

( defmethod:  cmdHelpCategory { 'cmdLook }	)
(    {[                         'it     ]}	)
(    [ "" |                              	)
( ;                                      	)

( =====================================================================	)

( - cmdHelp1 ---							)

( Return a short (less than one line) description of command.		)

defmethod:  cmdHelp1 { 'cmdLook }
    {[                   'it           ]}

    [ "Look at <something>." |
;


( =====================================================================	)

( - cmdHelpN ---							)

( Return a multi-line description of command.  Think of a manpage.	)

defmethod:  cmdHelpN { 'cmdLook }
    {[                   'it      ]}

    [
"Requests a text description of current surroundings."
    |
;

( --------------------------------------------------------------------- )
( - lookAtCurrentRoomContents ---					)

:   lookAtCurrentRoomContents { [] -> [] }
        |shift -> name
    ]pop

    ( Print names and short descriptions of room contents: )
    @.task.taskState.thisRoomCache -> cache
    [ cache | oldmud:allRoomObjects
	|for o do{
	    [ cache o | oldmud:roomObjectInfo
		:name   |get -> objName
		:short  |get -> short
		:can    |get -> can
	    ]pop	
	    short   short "" !=   and if
		[ "In " name " you see   " objName ",   " short ". " |
		    o   |push
		    can |push oldmud:lookAtCan
		]join echo
	    else
		[ "In " name " you see   " objName ". " |
		    o   |push
		    can |push oldmud:lookAtCan
		]join echo
	    fi
	}
    ]pop

    [ |
;

( --------------------------------------------------------------------- )
( - lookAtCurrentRoom ---						)

:   lookAtCurrentRoom { [] -> [] }
        |shift -> obj
        |shift -> name
        |shift -> can
    ]pop
    [ name can | ]vec -> fa

    ( Print name and description of room proper: )
    [   :op 'oldmud:REQ_VIEW
	:to  obj
	:a0 "in"
	:a1 "plain"
	:fa fa
	:fn ::  { [] -> [] }
		|shift -> fa
		|shift -> taskId
		|shift -> from
		|shift -> to
		|shift -> a0
		|shift -> a1
		|shift -> err
		|shift -> strId
		|shift -> strLen
		|shift -> short
	    ]pop
	    fa[0] -> name 
	    fa[1] -> can

	    strId not if
		short string? not if
		    @.task.taskState.thisRoomCache.roomShort -> short
		fi
		short   short "" !=   and if
		    [ "You see " name ", " short ". " |
		        to  |push
			can |push oldmud:lookAtCan
                    ]join echo
		else
		    [ "You see " name ". " |
		        to  |push
			can |push oldmud:lookAtCan
		    ]join echo
		fi
		[ name | lookAtCurrentRoomContents ]pop
	    else

		( Schedule first part of string to print: )
		[   :op 'oldmud:REQ_SUBSTRING
		    :to to
		    :a0 strId
		    :a1 0
		    :a2 500
		    :fa [ "You see " name to can | oldmud:lookAtCan ", " |push ]join
		    :fn 'echoCompleteString
		|   ]request
		[ name | lookAtCurrentRoomContents ]pop
	    fi

	    [ |
	;
    |   ]request


    [ |
;

( --------------------------------------------------------------------- )
( - lookAtSomethingsContents ---					)

:   lookAtSomethingsContents { [] -> [] }
        |shift -> name
        |shift -> obj
    ]pop

    ( Scope out what's in the object: )
    [   :op 'oldmud:REQ_NUMBER_HOLDING
	:to obj
	:fa name
	:fn :: { [] -> [] }
	    |shift -> name		( fa	)
	    |shift -> taskId
	    |shift -> from
	    |shift -> obj		( to	)
	    |shift -> err		( r0	)
	    |shift -> n			( r1	)
	    ]pop
	    err if err errcho   [ | return fi

	    ( Defend against being spammed by things   )
	    ( that claim to contain a billion objects: )
	    n 20 > if
		20 -> n
		"* look: Ignoring all but " n toString join " of contents. *" join echo
	    fi

	    ( Ask for the skinny on each object: )
	    for i from 0 below n do{
		[   :op 'oldmud:REQ_NTH_HOLDING
		    :to obj
		    :a0 i
		    :fa name
		    :fn :: { [] -> [] }
			|shift -> name		( fa	)
			|shift -> taskId
			|shift -> from
			|shift -> obj		( to	)
			|shift -> i		( a0	)
			|shift -> err		( r0	)
			|shift -> o		( r1	)
			]pop

			( Obj claims o is present: )
			err not if

			    ( Ask o if it thinks it is present: )
			    [   :op 'oldmud:REQ_IS_HELD_BY
				:to o
				:a0 obj
				:fa name
				:fn :: { [] -> [] }
				    |shift -> name		( fa	)
				    |shift -> taskId
				    |shift -> from
				    |shift -> o		( to	)
				    |shift -> obj		( a0	)
				    |shift -> err		( r0	)
				    |shift -> present	( r1	)
				    |length 0 != if |shift else 0  fi -> can   ( r2 )
				    |length 0 != if |shift else "" fi -> nam   ( r3 )
				    |length 0 != if |shift else "" fi -> short ( r4 )
				    ]pop
				    err if err errcho [ | return fi

				    ( Remember object admits it is present: )
				    present if
					@.task.taskState.thisRoomCache -> it
					short it oldmud:normalizeShort -> short
					nam   it oldmud:normalizeName  -> nam
					[   "In " name " you see " nam
					|
					    short "" != if
						", "            |push	
						short           |push	
					    fi
					    "."                 |push	
					    @.task.taskState.showObjectFlags case{
					    on: :verbose
						can oldmud:canToVerboseText -> s
						s "" != if
						    "  ("  |push
						    s      |push
						    ")"    |push
						fi	
					    on: :compact
						can oldmud:canToText -> s
						s "" != if
						    "  ("  |push
						    s      |push
						    ")"    |push
						fi	
					    }
					]join echo
				    fi

				   [ |
			        ;
			    |   ]request
			fi

		        [ |
		    ;
	        |   ]request
	    }

	    [ |
	;
    |   ]request

    [ |
;

( --------------------------------------------------------------------- )
( - lookAtSomething ---						)

:   lookAtSomething { [] -> [] }
        |shift -> obj
        |shift -> name
    ]pop

    ( Print name and description of object proper: )
    [   :op 'oldmud:REQ_VIEW
	:to  obj
	:a0 "out"
	:a1 "plain"
	:fa name
	:fn ::  { [] -> [] }
		|shift -> name
		|shift -> taskId
		|shift -> from
		|shift -> obj
		|shift -> a0
		|shift -> a1
		|shift -> err
		|shift -> strId
		|shift -> strLen
		|shift -> short
	    ]pop

	    err if err errcho [ | return fi

	    name "me" = if "yourself" -> name fi

	    strId not if
		short string? if
		    short @.task.taskState.thisRoomCache oldmud:normalizeShort -> short
		    [ "You see " name ", " short "." | ]join echo
		    [ name obj | lookAtSomethingsContents ]pop
		else
		    [ "You see " name "." | ]join echo
		    [ name obj | lookAtSomethingsContents ]pop
		fi
	    else

		( Schedule first part of string to print: )
		[   :op 'oldmud:REQ_SUBSTRING
		    :to obj
		    :a0 strId
		    :a1 0
		    :a2 500
		    :fa "You see " name join ", " join
		    :fn 'echoCompleteString
		|   ]request
		[ name obj | lookAtSomethingsContents ]pop
	    fi

	    [ |
	;
    |   ]request

    [ |
;

( --------------------------------------------------------------------- )
( - cmdDo ---								)

( Actually execute command.						)

defmethod: cmdDo { 'cmdLook 't  't     }
	|shift -> it
	|shift -> av
	|shift -> cmdName
	|downcase
    ]join -> name

    av.thisRoomCache -> cache
    [ cache name | oldmud:resolveName ]-> obj
    obj not if
	"*** Sorry: Can't find \"" name join "\" *" join echo
	[ | return
    fi

    obj cache.room = if
	[ obj cache.roomName cache.roomCan | lookAtCurrentRoom ]pop
    else
	[ obj name | lookAtSomething ]pop
    fi

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
