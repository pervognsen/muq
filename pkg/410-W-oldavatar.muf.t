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

( - 410-W-oldavatar.muf -- Avatars for rooms-and-exits islekit.	)
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

( =-------------------------------------------------------------------- )
(									)
(	For Mike Jittlov: A wiz of a wiz if ever there was!		)
(									)
( =-------------------------------------------------------------------- )

( =-------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      97Jul10, from 33-W-oldmud.t				)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1997, by Jeff Prothero.				)
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
( =--------------------------------------------------------------------	)

( =====================================================================	)
( - Quip								)

( =--------------------------------------------------------------------	)
(									)
(  Q: How do you know when a geek has broken up?			)
(  A: Sudden flurry of passphrase-changing!				)
(									)
( =--------------------------------------------------------------------	)

( =====================================================================	)
( - Package 'oldmud', exported symbols --				)

"oldmud" inPackage





( =====================================================================	)

( - Functions -								)

( =====================================================================	)
( - enterDefaultAvatarHandlers -- Convenience fn.			)

:   enterDefaultAvatarHandlers { $ $ $ -> }
    -> c
    -> f
    -> n

    n f c enterDefaultThingHandlers
    n f c enterDefaultRoomHostHandlers
    n f c enterDefaultWhoUserHandlers
;
'enterDefaultAvatarHandlers export

( =====================================================================	)

( - Private static variables						)

'_avatarOpNames   not bound? if makeStack --> _avatarOpNames   fi
'_avatarOpFns     not bound? if makeStack --> _avatarOpFns     fi
'_avatarOpClasses not bound? if makeStack --> _avatarOpClasses fi

_avatarOpNames   reset
_avatarOpFns     reset
_avatarOpClasses reset

_avatarOpNames _avatarOpFns _avatarOpClasses enterDefaultAvatarHandlers

( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - avatar -- Manifestation of a user.					)

defclass: avatar
    :export t
    :isA 'roomHost
    :isA 'pub:home
    :isA 'shellHost
    :isA 'viewableAavatar	( Must precede :IS-A 'THING to work.	)
    :isA 'thing
    :isA 'whoUser

    :slot :homeIsle	:prot "rw----"
    :slot :homeRoom	:prot "rw----"

    :slot :fullName	:prot "rwr-r-"
    :slot :publicKey	:prot "rwr-r-"		( Public pgp key.	)

    :slot :thisRoomCache	:prot "rw----"	:initform :: 'roomCache makeInstance ;

    :slot :showObjectFlags	:prot "rw----"  :initval  :verbose
;

( =====================================================================	)
( - av -- An abbreviation for 'avatar'.					)

( Sorry, I just got tired of typing all those letters! *wrygrin*	)

'avatar$s.type --> 'av$s.type
'av export


( =====================================================================	)
( - updateAvatarCanFlags -- 						)

:  updateAvatarCanFlags { $ -> }
    -> me
    me.publicViewState -> s

    CAN_AVATAR CAN_HEAR + CAN_NOTE_ROOM_CONTENTS + -> can
    s.viewExteriorText s.viewInteriorText or if can CAN_TEXT_VIEW + -> can fi
    s.viewExteriorHtml s.viewInteriorHtml or if can CAN_HTML_VIEW + -> can fi
    s.viewExteriorVrml s.viewInteriorVrml or if can CAN_VRML_VIEW + -> can fi
    can --> me.can
;

( =====================================================================	)

( - Public class creation functions -					)

( =====================================================================	)
( - makeAvvatar -- 							)

defgeneric: makeAvatar {[ $     $     ]} ;
defmethod:  makeAvatar { 't    't      } ;
defmethod:  makeAvatar { 't    'isle   }
    {[                   'name 'isle  ]}

    name isAString

    'avatar makeInstance -> avatar

    name             --> avatar.name

    "[" name "]" join join --> avatar.publicKey
    isle            --> avatar.homeIsle
    isle.nursery    --> avatar.homeRoom

    avatar updateAvatarCanFlags

    ( Publish fact that a.io input goes to a.daemonJob: )
    avatar --> avatar.liveDaemon
    ( Ditto for our aspects: )
    avatar --> avatar.mayNotViewState.liveDaemon
    avatar --> avatar.publicViewState.liveDaemon
    avatar --> avatar.friendViewState.liveDaemon
    avatar --> avatar.loverViewState.liveDaemon

    ( Establish shell to be run for avatar daemon: )
    ']daemon --> avatar.daemonShell	   ( Defaults to this anyhow.	)

    ( Define commands implemented by avatar daemon: )
    avatar _avatarOpNames _avatarOpFns _avatarOpClasses initLiveHandlers

    ( Update list of native avatars: )
    [ isle avatar | addToNativeList ]pop

    [ avatar |
;
'makeAvatar export


( =====================================================================	)

( - Generics and their methods -					)

( =====================================================================	)
( - doReqHasLeft -- Handle notification that an object has left.	)

defmethod:  doReqHasLeft { 'avatar 't  't  't  't  't 't 't   }
    {[                     'me     'it 'hu 'av 'id 'a 'b 'a2 ]}

    ( Relay the information to all our roomCaches: )
    [ me.thisRoomCache it hu av id a b a2 | doReqHasLeft ]pop

    [ nil |
;


( =====================================================================	)
( - doReqHasBeenEjected -- Notification that object has been ejected.	)

defmethod:  doReqHasBeenEjected { 'avatar 't  't  't  't  't 't 't   }
    {[                            'me     'it 'hu 'av 'id 'a 'b 'a2 ]}

    ( BUGGO, should handle specially the case that it is us being ejected )
    ( Or can we handle that in the roomCache itself? )

    ( Relay the information to all our roomCaches: )
    [ me.thisRoomCache it hu av id a b a2 | doReqHasBeenEjected ]pop

    [ nil |
;


( =====================================================================	)
( - doReqHasCome -- Handle notification that an object has arrived.	)

defmethod:  doReqHasCome { 'avatar 't  't  't  't  't 't 't   }
    {[                     'me     'it 'hu 'av 'id 'a 'b 'a2 ]}

    ( Relay the information to all our roomCaches: )
    [ me.thisRoomCache it hu av id a b a2 | doReqHasCome ]pop

    [ nil |
;


( =====================================================================	)
( - doReqHearPage -- Handle info that an object has paged.		)

defmethod:  doReqHearPage { 'avatar 't  't  't  't  't       't     't        }
    {[                      'me     'it 'hu 'av 'id 'speaker 'strId 'farIsle ]}

    me.homeIsle -> homeIsle
    homeIsle farIsle = if

        ( Speaker is native to our own isle -- look up name directly: )
	speaker remote? if [ nil | return fi
	[ homeIsle speaker | nativeFindEntry
	    |shift -> err
	    |shift -> avi
	    |shift -> lsi
	    |shift -> idi
	    |shift -> speakerName
	]pop

        speakerName not if [ nil | return fi

	( Schedule "page" string to print: )
	[   :op 'oldmud:REQ_SUBSTRING
	    :to speaker
	    :a0 strId
	    :a1 0
	    :a2 500
	    :fa speakerName " " join
	(   :fn 'echoCompleteString )
	    :fn :: { [] -> [] }
		'echoCompleteString call{ [] -> [] }
	    ;
	|   ]request

	[ nil | return
    fi

    ( Speaker is on another isle -- need to look up name on it: )

    ( First, look up name of the isle itself: )
    [ homeIsle farIsle | isleFindEntry
	|shift -> err
	|shift -> avi
	|shift -> lsi
	|shift -> idi
	|shift -> farIsleName
    ]pop		    
    err if [ nil | return fi

    ( Now, look up name of the paging avatar: )
    [   :op 'oldmud:REQ_FIND_LIST_ENTRY
	:to farIsle			( Isle hosting nativeList	)
	:a0 speaker			( Native to search list for	)
	:a1 "native"			( Name of native list to search	)
	:fa [ av strId farIsleName | ]vec
	:fn :: { [] -> [] }
	    |shift -> fa		( fa	)
	    |shift -> taskId
	    |shift -> from
	    |shift -> farIsle		( to	)
	    |shift -> speaker		( a0	)
	    |shift -> listName		( a1	)
	    |shift -> err
	    |shift -> avi
	    |shift -> lsi
	    |shift -> idi
	    |shift -> speakerName
	    ]pop		    
	    fa[0] -> av
	    fa[1] -> strId
	    fa[2] -> farIsleName

	    ( Schedule "page" string to print: )
	    [   :op 'oldmud:REQ_SUBSTRING
		:to speaker
		:a0 strId
		:a1 0
		:a2 500
		:fa [ speakerName "." farIsleName " " | ]join
	    (   :fn 'echoCompleteString )
		:fn :: { [] -> [] }
		    'echoCompleteString call{ [] -> [] }
		;
	    |   ]request

	    [ | return
	;
    |   ]request

    [ nil |
;


( =====================================================================	)
( - doReqHearSay -- Handle notification that an object has spoken.	)

defmethod:  doReqHearSay { 'avatar 't  't  't  't  't       't    't      }
    {[                     'me     'it 'hu 'av 'id 'speaker 'room 'strId ]}

    ( Find info for room.  Since at present we're only   )
    ( in one place at a time, this is currently trivial: )
    me.thisRoomCache -> cache
(    room cache.room != if [ "I'm not in that room" | return fi  )

    ( Get unambiguous name for speaker: )
    [ cache speaker | oldmud:roomObjectInfo
	:name nil |ged -> speakerName
    ]pop	
(    speakerName not if [ "You're not in that room" | return fi )

    ( Schedule "say" string to print: )
    [   :op 'oldmud:REQ_SUBSTRING
	:to speaker
	:a0 strId
	:a1 0
	:a2 500
	:fa speakerName " " join
(	:fn 'echoCompleteString )
	:fn :: { [] -> [] }
	    'echoCompleteString call{ [] -> [] }
	;
    |   ]request

    [ nil |
;


( =====================================================================	)
( - doReqHearWhisper -- Handle info that an object has whispered.	)

defmethod:  doReqHearWhisper { 'avatar 't  't  't  't  't       't    't      }
    {[                         'me     'it 'hu 'av 'id 'speaker 'room 'strId ]}

    ( Find info for room.  Since at present we're only   )
    ( in one place at a time, this is currently trivial: )
    me.thisRoomCache -> cache
(    room cache.room != if [ "I'm not in that room" | return fi  )

    ( Get unambiguous name for speaker: )
    [ cache speaker | oldmud:roomObjectInfo
	:name nil |ged -> speakerName
    ]pop	
(    speakerName not if [ "You're not in that room" | return fi )

    ( Schedule "whisper" string to print: )
    [   :op 'oldmud:REQ_SUBSTRING
	:to speaker
	:a0 strId
	:a1 0
	:a2 500
	:fa speakerName " " join
(	:fn 'echoCompleteString )
	:fn :: { [] -> [] }
	    'echoCompleteString call{ [] -> [] }
	;
    |   ]request

    [ nil |
;


( =====================================================================	)

( - More non-generic functions -					)

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

