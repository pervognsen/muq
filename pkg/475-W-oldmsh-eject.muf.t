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

( - 475-W-oldmsh-eject.muf -- Command for mudUser shell package.	)
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
( Created:      98Sep11, from 475-W-oldmsh-go.t				)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1999, by Jeff Prothero.				)
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
( - cmdEject ---							)

defclass: cmdEject
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

defmethod:  cmdNames { 'cmdEject }
    {[                  'it     ]}

    [ "@eject" |
;


( =====================================================================	)
( - cmdHelpCategory ---							)

( Following only needed if we change the return value to other than ""	)

( defmethod:  cmdHelpCategory { 'cmdEject }	)
(    {[                         'it      ]}	)
(    [ "" |                              	)
( ;                                      	)

( =====================================================================	)
( - cmdHelp1 ---							)

( Return a short (less than one line) description of command.		)

defmethod:  cmdHelp1 { 'cmdEject }
    {[                   'it    ]}

    [ "Kick someone out of your room." |
;


( =====================================================================	)
( - cmdHelpN ---							)

( Return a multi-line description of command.  Think of a manpage.	)

defmethod:  cmdHelpN { 'cmdEject }
    {[                 'it      ]}

    [
"@eject <name> will kick <name> out of the room.
You must own the room.  You may also want to
@gag them, to keep them from returning."
    |
;

( =====================================================================	)
( - cmdDo ---								)

( Actually execute command.						)

defmethod: cmdDo { 'cmdEject 't  't     }
(    {[            'it       'av 'name ]} )
        |shift -> it
        |shift -> av
        |shift -> name
    ]join -> objName

    av.thisRoomCache -> cache
    cache.room -> thisRoom
    thisRoom remote? if
	"You don't own this room" errcho
	[ | return
    else
	thisRoom$s.owner me != if
	    "You don't own this room" errcho
	    [ | return
	fi 
    fi 

    [ cache objName oldmud:CAN_AVATAR | oldmud:resolveName
        |shift -> obj
    ]-> can
    obj not if
	"No suitable '" objName join "' here" join errcho
	[ | return
    fi

#    "@eject isn't implemented yet" errcho

"@eject called...\n" log,

    ( Announce its ejection to everyone in the room: )
    [ cache | oldmud:allRoomObjects
	|for o do{
	    [ cache o | oldmud:roomObjectInfo
		:name   |get -> objName
		:short  |get -> short
		:can    |get -> can
	    ]pop	
	    can oldmud:CAN_NOTE_ROOM_CONTENTS logand 0 != if
[ "@eject notifying %s...\n" o | ]print log,
		[   :op 'oldmud:REQ_HAS_BEEN_EJECTED
		    :to o
		    :a0 obj
		    :a1 thisRoom
		|   ]request
	    fi
	}
    ]pop

[ "* Ejecting %s *" objName | ]print echo

#    [ av [ "@ejects '" objName "'" | ]join | oldmud:say ]pop

#    [ av.thisRoomCache av obj | oldmud:eject ]pop

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
