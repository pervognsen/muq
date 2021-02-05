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

( - 370-W-oldisle.muf -- Isles for rooms-and-exits islekit.		)
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
( ---------------------------------------------------------------------	)

( =====================================================================	)

( - Quote -								)

(   Let your soul stand cool and composed before a million universes.	)
( 									)
(					-- Walt Whitman			)


( =====================================================================	)
( - Package 'oldmud', forward declarations --				)

"oldmud" inPackage


( Forward declaration: )
"RMUD" rootValidateDbfile pop
[ "rootOldmud" .db["RMUD"] | ]inPackage

: rootInitMudUser   { [] -> [] ! } ;   'rootInitMudUser   export
: myrootInitMudUser { [] -> [] ! } ;   'myrootInitMudUser export

"oldmud" inPackage


( =====================================================================	)

( - Functions -								)


( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - isle -- collection of rooms, avatars &tc				)

( A isle instance contains slots for recording the name of		)
( the isle, for the sets of rooms and avatars in the isle,		)
( indexed by name, and for a pointer to the distinguished		)
( 'nursery' room in which new avatars appear:				)

defclass: isle
    :export t
    :isA 'roomHost
    :isA 'pub:home
    :isA 'nativeList
    :isA 'whoList
    :isA 'isleList
    :isA 'listServ
    :isA 'propServ

    ( 'avatar'  indexes all avatars by name;  )
    ( 'room'    indexes all rooms   by name:  )
    ( 'nursery' is the room in which newly    )
    (           created avatars are placed.   )
    ( 'quay'    is the room in which links    )
    (           to other isles are placed.    )

    :slot :name			:prot "rwr-r-"
    :slot :avatar		:prot "rw----"  :initform :: makeHash   ;
    :slot :lock			:prot "rw----"  :initform :: makeLock   ;
    :slot :nursery		:prot "rwr-r-"
    :slot :quay			:prot "rw----"
    :slot :crossroads		:prot "rw----"
    :slot :nurse		:prot "rw----"
    :slot :whoList		:prot "rw----"  :initform :: 'whoList makeInstance ;
    :slot :msgOfTheDay		:prot "rwr-r-"  :initval nil
    :slot :quayJanitorDelay	:prot "rwr-r-"  :initval 60000	( 1 min	)
    :slot :quayJanitorMax	:prot "rwr-r-"  :initval 1000
    :slot :welcomeMsg		:prot "rwr-r-"  :initval
"
----------------------------------------------------------------------------
|                          Welcome to Micronesia!                          |
|                                                                          |
| Micronesia is a virtual world seamlessly networked between Muq servers   |
| spread all over the Internet:  Each server implements one isle, but      |
| users can freely travel and communicate between isles exactly as they    |
| travel within isles: To the user, all connected servers combine to       |
| present a single unified world.                                          |
|                                                                          |
| The current release is a late alpha, still quite buggy.  Feel free to    |
| bang on it, but be prepared to live with the dbs being nuked every few   |
| days -- if they don't crash first.  *grin*                               |
|                                                                          |
| (Some) docs are online at http://muq.org/~cynbe/muq/muq.html.            |
| Bugs and suggestions may be mailed to bugs@muq.org.                      |
|                                                                          |
| Have fun, and remember -- no Muq is an island, sufficient unto itself!   |
|                                                                          |
| -- Cynbe  (cynbe@muq.org)                                                |
----------------------------------------------------------------------------

"

;







( =====================================================================	)

( =====================================================================	)

( - Public class creation functions -					)

( =====================================================================	)
( The CommonLisp Object System defines a weirdly			)
( wonderful set of facilities for controlling				)
( the creation and initialization of new instances			)
( of a class, but I have yet to implement all that			)
( in the Muq Object System, so for now I just write			)
( explicit initialization functions by hand:				)

( =====================================================================	)

( - Generics and their methods -					)

( =====================================================================	)
( - initializeIsle -- Clean up isle at server startup.			)

defgeneric: initializeIsle {[ $    ]} ;
defmethod:  initializeIsle { 'isle  }
    {[                       'isle ]}

    [ |
;
'initializeIsle		export

( =====================================================================	)

( - More non-generic functions -					)

( =====================================================================	)
( - enterIsleHandlers -- 						)

:   enterIsleHandlers { $ $ $ -> }
    -> c
    -> f
    -> n

    REQ_ISLE_QUAY 'doReqIsleQuay nil   n f c enterOp
;
'enterIsleFunctions export

( =====================================================================	)
( - enterDefaultIsleHandlers -- Convenience fn.				)

:   enterDefaultIsleHandlers { $ $ $ -> }
    -> c
    -> f
    -> n

    n f c enterDefaultRoomHostHandlers
    n f c enterDefaultLiveHandlers
    n f c enterDefaultListServHandlers
    n f c enterDefaultPropServHandlers
    n f c enterIsleHandlers
;
'enterDefaultIsleHandlers export

( =====================================================================	)

( - Private static variables						)

'_isleOpNames   not bound? if makeStack --> _isleOpNames   fi
'_isleOpFns     not bound? if makeStack --> _isleOpFns     fi
'_isleOpClasses not bound? if makeStack --> _isleOpClasses fi

_isleOpNames   reset
_isleOpFns     reset
_isleOpClasses reset

_isleOpNames _isleOpFns _isleOpClasses enterDefaultIsleHandlers

( =====================================================================	)
( - installBadlands -- Add procedurally defined rooms.			)

:   installBadlands { [] -> [] }
    |shift -> isle
    ]pop

    ( This is a null version of the function, which will	)
    ( be overridden by the *bad* libraries if installed.	)

    [ |
;

( =====================================================================	)
( - makeIsle -- Allocate a new isle definition.				)

:   makeIsle { $ -> $ }
    -> name 

    name isAString

    ( Create isle proper, set its type and name: )
    'isle makeInstance -> isle
    name            --> isle.name

    ( Define commands implemented by isle daemon: )
    _isleOpNames   --> isle.liveNames
    _isleOpFns     --> isle.liveFns
    _isleOpClasses --> isle.liveClasses

    ( Set up whoList support: )
    [   isle				( listServ instance	)
        "who"				( name of list		)
        isle				( whoList instance	)
        'doReqWhoListInfo		( list info fn		)
	'doReqWhoNextEntry		( list next fetch fn	)
	'doReqWhoPrevEntry		( list prev fetch fn	)
	nil				( list this fetch fn	)
	'doReqWhoFindEntry		( list entry find fn	)
	'doReqWhoJoinList		( list join fn		)
	'doReqWhoWuitList		( list quit fn		)
	nil				( list addTo fn	)
	nil				( list dropFrom fn	)
    |   addList ]pop

    ( Set up nativeList support: )
    [   isle				( listServ instance	)
        "native"			( name of list		)
        isle				( nativeList instance	)
        'doReqNativeListInfo		( list info fn		)
	'doReqNativeNextEntry		( list next fetch fn	)
	'doReqNativePrevEntry		( list prev fetch fn	)
	nil				( list this fetch fn	)
	'doReqNativeFindEntry		( list entry find fn	)
	'doReqNativeJoinList		( list join fn		)
	'doReqNativeQuitList		( list quit fn		)
	nil				( list addTo fn	)
	nil				( list dropFrom fn	)
    |   addList ]pop

    ( Set up isleList support: )
    [   isle				( listServ instance	)
        "isle"				( name of list		)
        isle				( isleList instance	)
        'doReqIsleListInfo		( list info fn		)
	'doReqIsleNextEntry		( list next fetch fn	)
	'doReqIslePrevEntry		( list prev fetch fn	)
	nil				( list this fetch fn	)
	'doReqIsleFindEntry		( list entry find fn	)
	'doReqIsleJoinList		( list join fn		)
	'doReqIsleQuitList		( list quit fn		)
	'doReqAddToIsleList		( list addTo fn	)
	nil				( list dropFrom fn	)
    |   addList ]pop

    [ "the_" name "_Nursery"    | ]join -> nurseryName
    [ "the_" name "_Quay"       | ]join -> quayName
    [ "the_" name "_Crossroads" | ]join -> crossroadsName

    ( Create nursery room in which new avatars appear: )
    [ nurseryName "birthroom of new avatars" isle | makeRoom ]-> nursery
    nursery --> isle.nursery
    nursery --> isle.room[nurseryName]

    ( Create quay room for links to other isles: )
    [ quayName "with boat service to other isles" isle | makeRoom ]-> quay
    quay --> isle.quay
    quay --> isle.room[quayName]

    ( Create crossroads room for links to user building: )
    [ crossroadsName "with roads to user-built areas" isle | makeRoom ]-> crossroads
    crossroads --> isle.crossroads
    crossroads --> isle.room[crossroadsName]
    ( Allow users to link new rooms: )
    crossroads.can oldmud:CAN_LINK + --> crossroads.can



    ( Create exitPair joining nursery and quay: )

    [ "N" "a path leading to the Quay"    isle | makeExit ]-> nurseryToQuay
    [ "S" "a path leading to the Nursery" isle | makeExit ]-> quayToNursery

    quayName    --> nurseryToQuay.exitDestination
    nurseryName --> quayToNursery.exitDestination

    nurseryToQuay --> quayToNursery.exitTwin
    quayToNursery --> nurseryToQuay.exitTwin

    nursery          nurseryToQuay enhold
    nurseryToQuay nursery          enheldBy

    quay            quayToNursery enhold
    quayToNursery quay            enheldBy



    ( Create exitPair joining quay and crossroads: )

    [ "E" "a road leading to the Crossroads" isle | makeExit ]-> quayToCrossroads
    [ "W" "a road leading to the Quay"       isle | makeExit ]-> crossroadsToQuay

    crossroadsName --> quayToCrossroads.exitDestination
    quayName       --> crossroadsToQuay.exitDestination

    quayToCrossroads --> crossroadsToQuay.exitTwin
    crossroadsToQuay --> quayToCrossroads.exitTwin

    quay               quayToCrossroads enhold
    quayToCrossroads quay               enheldBy

    crossroads          crossroadsToQuay enhold
    crossroadsToQuay crossroads          enheldBy



    ( For consistency of muqnet operation, equip root and muqnet )
    ( users with avatars so they are not special cases when it   )
    ( comes to updating user addresses after an IP address       )
    ( change, for example:                                       )
    .u["muqnet"] :oldmudAvatar systemGet? pop not if
	[ isle "muqnet" "muqnet" | rootOldmud:rootInitMudUser ]pop
    fi

    .u["root"]   :oldmudAvatar systemGet? pop not if
	[ isle "root"   "root"   | rootOldmud:rootInitMudUser ]pop
    fi

    ( Optional procedurally-defined stuff: )
    [ isle | installBadlands ]pop

    isle
;
'makeIsle export

( =====================================================================	)
( - quayJanitorTask -- Keep proa exits in Quay up to date, &tc		)

:   quayJanitorTask { [] -> [] }    ( Called every 30 sec or whatever	)
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask/aaa\n" d, )
    |shift -> taskId
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask taskId=" d, taskId d, "\n" d, )
    |shift -> why	( text name	)
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask why=" d, why d, "\n" d, )
    |shift -> me	( isle	)
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask me=" d, me d, "\n" d, )
    ]pop    

    ( Schedule another repeat of us to execute: )
    me.quayJanitorDelay -> delayTime
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask starting, delayTime = " d, delayTime d, "\n" d, )
    [ @.task delayTime taskId why 'quayJanitorTask me | task:inDo ]pop
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask punching in a no-op...\n" d, )
    [ me | oldmud:doNop ]pop

    ( Pick a known isle at random: )
    me.isleListLock withLockDo{
	me.isleId            -> id
	me.isleName          -> wn
	me.isleListedSince  -> ls
	me.isleIsle          -> wd
	wd length             -> len
	frandom len * floor   -> i
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask i=" d, i d, "\n" d, )
	0 len = if [ | return fi
	i len = if -- i fi
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask i=" d, i d, "\n" d, )
	id[i] -> idi
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask idi=" d, idi d, "\n" d, )
	wd[i] -> isle
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask isle=" d, isle d, "\n" d, )
	ls[i] -> lsi
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask lsi=" d, lsi d, "\n" d, )
	wn[i] -> nam
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask nam=" d, nam d, "\n" d, )
    }

    ( Remind isle that we exist: )
    [   :op 'oldmud:REQ_ADD_TO_LIST
	:to  isle
	:a0 "isle"	( Name of list to modify.	)
	:a1 me		( Object to add.		)
	:a2 me.name	( Name of object to add.	)
	:am "quayJanitor/REQ_ADD_TO_LIST"
	:errFn :: { [] -> [] }
	    |shift -> taskId
	    |shift -> isle
	    |shift -> a0
	    |shift -> me
	    |shift -> meName
	    ]pop

	    [ me isle | noteIsleSank ]pop

	    [ |
	;
    |   ]request

    ( See if remote isle knows of any new isles:	)
    ( [ me isle | suckNewIsleDry ]pop		        )
    ( Above seems to be a bad idea: After an isle sinks	)
    ( and we delete it, we promptly get it back from	)
    ( some other isle that hasn't noticed it sinking(?)	)
    ( Can we rehack so we take isles seen elsewhere as  )
    ( hints, but don't actually enter them unless we    )
    ( contact them directly...?                         )

    [ |
( .sys.muqPort d, "(370)<" d, @ d, ">quayJanitorTask.zzz\n" d, )
;

( =====================================================================	)
( - startQuayJanitorTask -- support fn for wakeLiveDaemon method	)

:   startQuayJanitorTask { [] -> [] }
( .sys.muqPort d, "(370)<" d, @ d, ">startQuayJanitorTask/aaa\n" d, )
    |shift -> me
( .sys.muqPort d, "(370)<" d, @ d, ">startQuayJanitorTask me=" d, me d, "\n" d, )
    ]pop

    ( IN-DO args are:							)
    (    US    task:home instance.					)
    (    WHEN  seconds to wait before executing FN.			)
    (    ID    usually NIL, else integer to use as task id.		)
    (    WH    NIL, else text string naming task for human displays.	)
    (    FN    Function to invoke when time is up, else NIL.		)
    (          FN is passed task id followed by ARGS.			)
    (    ARGS  All remaining ARGS (up to 13) are passed to FN.		)
    (	   All but the first TARGS of the ARGS are passed to IOFN.	)

    ( Submit job to the delayedExecution queue: )
    me.quayJanitorDelay -> delayTime
( .sys.muqPort d, "(370)<" d, @ d, ">startQuayJanitorTask delayTime=" d, delayTime d, "\n" d, )
    nil                   -> taskId
( .sys.muqPort d, "(370)<" d, @ d, ">startQuayJanitorTask starting it, delayTime = " d, delayTime d, "\n" d, )
    [ @.task delayTime taskId "quayJanitor" 'quayJanitorTask me | task:inDo ]pop

    ( Send a NOP to wake the daemon so it will schedule above: )
    [ me | oldmud:doNop ]pop

    [ |
( .sys.muqPort d, "(370)<" d, @ d, ">startQuayJanitorTask/zzz\n" d, )
;

( =====================================================================	)
( - wakeLiveDaemon -- Method.						)

defmethod:  wakeLiveDaemon { 'isle }
    {[                       'me   ]}

    ( Give isleDaemon time to initialize.          )
    ( This may be needed to establish w/daemonTask: )
    1000 sleepJob		( Buggo, nasty little race condition.		)
    me.daemonTask --> @.task		( Needed by ]request-* calls.	)

    ( Update proas in Quay, & related stuff: )
( .sys.muqPort d, "(370)<" d, @ d, ">oldisle: wakeLiveDaemon calling updateIslesList...\n" d, )
    [ me | updateIslesList ]pop

    ( Start task to keep proas in Quay up to date: )
    [ me | startQuayJanitorTask ]pop

    [ |
;

( =====================================================================	)
( - doReqIsleQuay -- 							)

defgeneric: doReqIsleQuay {[ $     $   $   $   $   $   $   $  ]} ;
defmethod:  doReqIsleQuay { 't    't  't  't  't  't  't  't   } "doReqIsleQuay" gripe ;
defmethod:  doReqIsleQuay { 'isle 't  't  't  't  't  't  't   }
    {[                      'me   'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    [ nil me me.quay.name |
;
'doReqIsleQuay export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

