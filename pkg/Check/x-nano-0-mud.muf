( - 300-X-nanomud.muf -- Skeleton mudWorld package.			)
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
( Created:      94Sep18							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1995-1997, by Jeff Prothero.				)
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
( - Epigram.								)

( "A community is a group of people who have a shared past, hope 	)
(  to have a shared future, have some means of acquiring new     	)
(  members, and have some means of recognising and maintaining   	)
(  differences between themselves and other communities."        	)
(     -- Sharon Traweek, _Beamtimes and Lifetimes_.              	)

( =====================================================================	)
( - Overview.								)

( 30-X-nanomud together with 31-X-nanomsh are intended as a		)
( programming example demonstrating the basic mechanics of		)
( a multi-user application under Muq.  The intent is to include		)
( just enough code to illustrate these mechanics realistically,		)
( without getting bogged down in all of the detail work of a		)
( full-scale multi-user application.					)
(									)
( I have also attempted to illustrate what I regard as good Muq		)
( programming practices on a number of levels. In particular:		)
(									)
( => The nanomud and its matching shell (nanomsh) are completely	)
(    separate packages.  A quite different shell could be written	)
(    without modifying the nanomud proper.				)
(									)
( => There is no requirement that the nanomud and nanomsh files		)
(    be owned and maintained by the same user account:  A new		)
(    shell can be written, tested and used without modifying		)
(    or owning the nanomud package.					)
(									)
( => The nanomsh shell makes no use whatever of Muq root		)
(    privileges:  It can be written and maintained without		)
(    sysadmin intervention.						)
(									)
( => The nanomud itself makes almost no use of Muq root			)
(    privileges:  They are invoked only for creating and		)
(    logging in users, something which in a production			)
(    Muq environment would likely be done by separate system		)
(    code, but which I have left merged into this file for		)
(    didactic clarity.							)
(									)
( => Except where it would unduly complicate the code, I have		)
(    tried to present a realistic design and implementation fairly	)
(    balancing the security, reliability, and privacy interests		)
(    of the various participants:					)
(									)
(    -> The worldkit uses asMeDo{...}	to authenticate messages	)
(	it sends to players, where appropriate, first performing	)
(	reasonable checks that it is not being spoofed.			)
(									)
(    -> The avatar is owned by the user operating it, so as to		)
(	not count against the owner of the world.			)
(									)
(    -> Appropriate fields in the avatar are writable only by the	)
(	world owner, allowing the world owner the last word on who	)
(	is allowed to enter a room and such.				)
(									)
(    -> Other fields in the avatar are writable only by user,		)
(	such as the description -- which is not actually used		)
(	by the current code, but easily could be.			)
(									)
(    -> The user shell is notified of all listeners in a		)
(	room on arrival, and of all changes to that list,		)
(	and prints these forthe user in spoof-proof fashion.		)
(	The player shell sends 'say' and 'pose' messages to		)
(	all listeners on its own, without invoking worldkit		)
(	code, bypassing a number of possibilities for unwanted		)
(	eavesdropping.							)
(									)
(    -> The user shell performs reasonable authentication on		)
(	input recieved before showing it to the user.			)


( =====================================================================	)
( -- Package 'nanomsh', exported symbols --				)

( The 'nanomsh' package actually loads after )
( us, but we need to predeclare the ]shell   )
( function now so that we can refer to it:   )

"nnsh" rootValidateDbfile pop
[ "nanomsh" .db["nnsh"] | ]inPackage
( "nanomsh" inPackage )
"]shell" intern
'nanomsh::]shell   export

( Dummy temporary definition just to declare )
( arity and that ]shell is in fact a fn:     )
: ]shell { [] -> @ } ]pop do{ } ;

( =====================================================================	)
( - Package 'nanomud', exported symbols --				)

"nnmu" rootValidateDbfile pop
[ "nanomud" .db["nnmu"] | ]inPackage
( "nanomud" inPackage )

'start				export	( Starts mud on port 32000 )
'startMud			export	( Starts any valid mudworld )

'noteAvatar			export
'makeExit			export
'makeRoom			export
'makeWorld			export

'describeLocation		export
'getLocationExits[		export
'getLocationListeners[	export

'move				export
'quit				export
'welcomeUser			export

"nanomudVars" inPackage

'_world				export

( Mark default world as uncreated: )
nil --> _world

"nanomud" inPackage

( =====================================================================	)
( - Overview -								)

( This file implements the Muq nanomud, a simple demonstration		)
( of the mechanics of implementing a mud on top of Muq.  This		)
( file works in conjunction with 41-msh.muf, which implements		)
( a similarly sketchy user shell.                             		)
(									)
( If you have both files loaded into your db, you can start		)
( up the mud just by doing "nanomud:start" as Root on the console.	)
(									)
( This code is extremely preliminary, intended more as a 		)
( toy and proof of principle than as anything of lasting		)
( import.  No lasting support for this package is promised.		)



( =====================================================================	)

( - Classes -								)


( =====================================================================	)
( - exit -- passageway between two rooms				)

defclass: exit
    :export t

    :slot :name
    :slot :dst		( Room in which exit starts.	)
    :slot :src		( Room to which exit leads.	)
    :slot :world
    :slot :description
          :initval "You see an exit which hasn't been described yet."
;


( =====================================================================	)
( - room -- location for avatars					)

defclass: room
    :export t

    :slot :name
    :slot :dst	  ( Exits leading into this room. ) :initform :: makePlain ;
    :slot :src    ( Exits leading from this room. ) :initform :: makePlain ;
    :slot :avatar ( Avatars in this room.         ) :initform :: makePlain ;
    :slot :world
    :slot :description
          :initval "You see a room which hasn't been described yet."
;

( =====================================================================	)
( - world -- collection of rooms, avatars &tc				)

defclass: world
    :export t

    ( 'avatar'  indexes all avatars by name;  )
    ( 'room'    indexes all rooms   by name:  )
    ( 'nursery' is the room in which newly    )
    (           created avatars are placed.   )
    ( 'job'     is the daemon animating world )

    :slot :name
    :slot :avatar	:initform :: makePlain ;
    :slot :room		:initform :: makePlain ;
    :slot :nursery
    :slot :lock		:initform :: makeLock   ;
    :slot :job		:initval  nil
;


( =====================================================================	)
( - avatar -- Manifestation of a user.					)

defclass: avatar
    :export t
    :fertile nil

    :slot :name
	:userMayRead  t	:userMayWrite  nil
	:classMayRead t	:classMayWrite t
	:worldMayRead t	:worldMayWrite nil

    :slot :world
	:userMayRead  t	:userMayWrite  nil
	:classMayRead t	:classMayWrite t
	:worldMayRead t	:worldMayWrite nil

    :slot :location
	:userMayRead  t	:userMayWrite  nil
	:classMayRead t	:classMayWrite t
	:worldMayRead t	:worldMayWrite nil

    :slot :standardInput
	:userMayRead  t	:userMayWrite  t
	:classMayRead t	:classMayWrite nil
	:worldMayRead t	:worldMayWrite nil


    :slot :description
        :initval "You see someone who hasn't set their description yet."
	:userMayRead  t	:userMayWrite  t
	:classMayRead t	:classMayWrite nil
	:worldMayRead t	:worldMayWrite nil
;



( =====================================================================	)

( - Class creation functions -						)


( =====================================================================	)
( - makeExit -- Allocate a new location operator object.		)

:   makeExit { $ $ $ $ -> }
    -> dst		dst   isARoom
    -> src		src   isARoom
    -> name		name  isAString
    -> world		world isAWorld

    ( ++++++++++++++++++++++++++++++++++++++++ )
    ( This function makes and installs an exit )
    ( 'name' located in 'world' linking room   )
    ( 'src' to room 'dst':                     )
    ( ++++++++++++++++++++++++++++++++++++++++ )

    src.world world != if
        "makeExit 'src' arg is in wrong world" simpleError
    fi
    dst.world world != if
        "makeExit 'dst' arg is in wrong world" simpleError
    fi
    src.src name get? pop if
        [   "makeExit: room '%s' already has an exit named '%s'!"
	    src.name
	    name 
	| ]print simpleError
    fi
    dst.dst name get? pop if
        [   "makeExit: room '%s' already has an entrance named '%s'!"
	    src.name
	    name 
	| ]print simpleError
    fi

    ( Create and initialize exit: )
    'exit makeInstance -> exit

    name   --> exit.name
    dst    --> exit.dst
    src    --> exit.src
    world  --> exit.world

    ( Record exit in rooms it links: )
    world.lock withLockDo{
        exit   --> src.src[name]
        exit   --> dst.dst[name]
    }
;

( =====================================================================	)
( - makeRoom -- Allocate a new user placeToBe object.			)

:   makeRoom { $ $ -> $ }
    -> name
    -> world

    ( Create a room 'name' in 'world': )

    ( Sanity checks: )
    name  isAString
    world isAWorld
    world.room name get? pop if
	[   "This world already contains a '%s' room" name
	| ]print simpleError
    fi

    ( Create and initialize room: )
    'room makeInstance -> room
    name   --> room.name
    world  --> room.world

    ( Record room in world: )
    world.lock withLockDo{
        room   --> world.room[name]
    }

    ( Return room: )
    room
;

( =====================================================================	)
( - makeWorld -- Allocate a new setOfAvatars object.			)

:   makeWorld { $ -> $ }
    -> name 

    name isAString

    ( Create world proper, set its type and name: )
    'world makeInstance -> world
    name    --> world.name

    ( Create birthroom: )
    world "Nursery" makeRoom -> nursery

    "You see lots of cradles and a harried-looking nurse."
    --> nursery.description

    nursery --> world.nursery

    world
;

( =====================================================================	)
( - noteAvatar -- Register a new user point-of-presence object.		)

:   noteAvatar { $ $ $ -> }
    -> avatar			avatar  isAAvatar
    -> name			name	isAString
    -> world			world	isAWorld

    world.avatar name get? pop if
	[ "noteAvatar: world already has a '%s'" name
	| ]print simpleError
	
    fi

    ( Create and initialize avatar: )
    asMeDo{
	name               --> avatar.name
	world              --> avatar.world
	world.nursery      --> avatar.location

	( Add avatar to global nameIndexed )
	( worldlist of existing avatars:    )
	world.lock withLockDo{
	    avatar   --> world.avatar[name]
	}
    }
;

( =====================================================================	)

( - Public fns -							)


( =====================================================================	)
( - disconnectAllAvatars -- Mark all avatars as disconnected.		)

:   disconnectAllAvatars { $ -> }
    -> world

    ( Sanity checks: )
    world isAWorld

    world.lock withLockDo{
	world.avatar foreach name avatar do{
	    delete: avatar.location.avatar[name]
	}
    }
;

( =====================================================================	)
( - describeLocation -- Print text description.				)

:   describeLocation { $ -> }
    -> avatar			avatar isAAvatar

    avatar.location -> loc	loc isARoom

    loc.description ,
;

( =====================================================================	)
( - getLocationExits[ -- Return block of location exits.		)

:   getLocationExits[ { $ -> [] }
    -> avatar			avatar isAAvatar

    avatar.location -> loc	loc isARoom

    loc.src keys[ 
;

( =====================================================================	)
( - getLocationListeners[ -- Return block of listening avatars.		)

:   getLocationListeners[ { $ -> [] }
    -> avatar			avatar isAAvatar

    avatar.location -> loc	loc isARoom

    loc.avatar vals[ 
;

( =====================================================================	)
( - notifyExcept -- Send string to all listeners but one in room	)

:   notifyExcept { $ $ $ -> }
    -> self	( Avatar arriving or departing			)
    -> what	( One of :connect :disconnect :depart :arrive	)
    -> room

    t -> done

    self  isAAvatar
    room  isARoom

    self.world$s.owner me != if
        "Must own world to call nanomud:notifyExcept" simpleError
    fi

    ( Over all listeners in room, except self: )
    room.avatar vals[ 
	|for a do{
	    a self != if

		( Fire off our message: )
		[ self |
                    what done a.standardInput
                    |maybeWriteStreamPacket
		    pop pop
                ]pop
	    fi
	}
    ]pop
;

( =====================================================================	)
( - move -- Attempt to move an avatar from one room to another.		)

:   move { $ $ -> $ $ }
    -> exitName			exitName isAString
    -> avatar				avatar    isAAvatar
    avatar.world -> world		world     isAWorld

    avatar.name     -> avatarName	avatarName isAString
    avatar.location -> src		src isARoom

    src.src exitName get? -> exit not if
        nil [ "I see no '%s' exit!" exitName | ]print return
    fi

    exit.dst -> dst			dst isARoom

    ( Do the move: )
    asMeDo{
	world.lock withLockDo{
	    delete:    src.avatar[avatarName]
	    avatar --> dst.avatar[avatarName]
	    dst    --> avatar.location
	}

	( Notify folk in src.dst rooms of move: )
	src :depart avatar notifyExcept
	dst :arrive avatar notifyExcept
    }

    t [ "You pass through exit '%s' into room '%s'\n" exit.name dst.name | ]print
;

( =====================================================================	)
( - quit -- Disconnect a user.						)

:   quit { $ -> @ }
    -> avatar				avatar isAAvatar
    avatar.world -> world		world  isAWorld

    ( Allow only owner of an   )
    ( avatar to disconnect it: )
    @.actingUser avatar$s.owner != if
	"Only avatar owner may do 'quit' on it" simpleError
    fi

    avatar.name     -> avatarName	avatarName isAString
    avatar.location -> src		src isARoom

    ( Remove avatar from room: )
    asMeDo{
	world.lock withLockDo{
            delete: src.avatar[avatarName]
	}

        ( Notify others in room of the disconnect: )
        src :disconnect avatar notifyExcept
    }

    ( Notify avatar of departure: )
    [ "Come again!\n" | ]print ,

    ( Give farewell message a tick or two )
    ( to get printed.  This may be quite  )
    ( unnecessary:			  )
    switchJob
    switchJob

    ( Close the socket if we can find it: )
    @.jobSet.session -> session
    session.socket -> socket
    socket socket? if
	[ :socket socket | ]closeSocket
    fi

    ( Shut down this job: )
    nil endJob
;

( =====================================================================	)
( - rootLoginUser -- Identify and validate a connecting user.		)

:   rootLoginUser { -> $ ! } 

    ( Start up a telnet daemon so    )
    ( we can do passphrase blanking: )     
( buggo, this may be a security problem --   )
( should perhaps have a secure telnet daemon )
( supporting fewer commands for here.        )
    telnet:start
    do{

	( Read purported name of user from net: )
	"login:\n" ,
	readLine trimString     -> userName
	.u userName get? -> user pop
		
	( It is a good habit to prompt for pass- )
	( word even if user name is wrong:       )
	telnet:willEcho	( Suppress echoing during pw entry. )
	"passphrase:\n" ,
	readLine trimString -> passphrase
	telnet:wontEcho	( Restore normal echoing.	)
	
	( The envelope please... )
	user if
	    passphrase vals[
		'z' |unshift
		'z' |unshift
		|secureHash |secureHash
	    user$a.encryptedPassphrase |= if ]pop

		( Shut down telnet daemon because  )
		( it is running as root, and we'll )
		( want one owned by the user:      )
		telnet:stop

		( Convert to running as new user: )
		user rootBecomeUser
	    else
		]pop
	    fi
	fi

	"Sorry!\n" ,
	5000 sleepJob	( To slow down passphrase-guessing attacks.	)
    }
;

( =====================================================================	)
( - welcomeUser -- Issue appropriate welcome message etc.		)

:   welcomeUser { $ -> }
    -> avatar

    "Welcome to the Muq nanomud!\n" ,

    ( Enter avatar into correct room: )
    avatar.name     -> name
    avatar.location -> room
    asMeDo{
	avatar --> room.avatar[name]

        ( Notify otherfolk of the connection: )
        room :connect avatar notifyExcept
    }
;

( =====================================================================	)
( - spawnUser -- Start user shell on given skt.				)

:   spawnUser { $ $ -> ! }
    -> newSkt
    -> world

    ( Spawn a new user shell and connect it to new skt: )
    "nanoUser" forkSession -> amParent	   ( Child gets NIL, parent gets child. )
    amParent not if

	( We're the child session: )

	( Create new input.output streamPair for ourself: )
        makeBidirectionalMessageStream
	-> standardInput	( jobToSocket )
	-> standardOutput	( socketToJob )

	( Hook new streams up to skt: )
	standardInput  --> newSkt.standardInput
	standardOutput --> newSkt.standardOutput

	( Find our session: )
	@.jobSet.session -> session

	( Introduce skt and session to each other: )
	session --> newSkt.session
	newSkt --> session.socket

	( Hook new streams up to ourself: )
	standardInput  --> @.standardInput
	standardInput  --> @.standardOutput
	standardInput  --> @.terminalIo
	standardInput  --> @.queryIo
	standardInput  --> @.debugIo
	standardInput  --> @.errorOutput
	standardInput  --> @.traceOutput

        rootLoginUser
	( Above should never return. )
    fi
;

( =====================================================================	)
( - startMud -- Start selected world.					)

:   startMud { $ $ -> }
    -> port
    -> world

    ( Fork off a separate process to listen for connects: )
    "nanomud" forkJob -> amParent	( Child gets NIL, parent gets child. )
    amParent if
	[ "Started nanomud on port %d.\n" port | ]print ,
	"Logins are 'nano1' passphrase 'nano1' and 'nano2'/'nano2'.\n" ,
	[   "Do 'telnet localhost %d' at unix prompt to connect to nanomud.\n"
            port
        | ]print ,
    else

	( We're the child process: )
	@ --> world.job

	( Clean up for new run: )
	world disconnectAllAvatars

	( Make ourself a new input message stream: )
	makeMessageStream --> @.standardInput

	( Tell server to actually start listening for connects: )
	makeSocket    -> socket
	@.standardInput --> socket.standardOutput
        [   :socket socket
	    :port   port
        | ]listenOnSocket

	( Loop indefinitely, accepting connects )
        ( and spawning user shells:             )
	do{
	    ( Read one who+msg pair from )
	    ( the port listener:         )
	    @.standardInput readStreamLine -> newSkt -> opcode

	    ( 'opcode' distinguishes the different messages  )
	    ( which the port listener might wish to send us. )
	    (						     )
	    ( Currently the only such opcode defined is      )
	    ( "new", in which case 'newSkt' is a new skt    )
	    ( instance representing a new network	     )
	    ( connection:				     )
	    opcode case{	

	    on: "new"
		world newSkt spawnUser

	    else:
		( Should log a system error here, )
		( but don't have any logging      )
		( facilities defined yet.	  )
	    }
        }
    fi
;

( =====================================================================	)
( - rootMakeNanomudUser -- Make user account for simple test world.	)

:   rootMakeNanomudUser { $ $ $ -> }
    -> encryptedPassphrase
    -> world
    -> name

    name rootMakeAUser
    .u[name] -> user
    encryptedPassphrase --> user$a.encryptedPassphrase

    ( Make user's package the current package, )
    ( so that avatar will be created in user's )
    ( dbfile and -- hence -- owned by user:    )
    @.package -> oldPkg    ( Save current pkg )
    user$s.defaultPackage -> pkg
    pkg --> @.package      ( Buggo, need 'inPackageDo{ ... }' )
    user rootAsUserDo{
        'avatar makeInstance -> avatar
	world name avatar noteAvatar
    }
    oldPkg --> @.package

    world  --> user$s.nanomudWorld
    avatar --> user$s.nanomudAvatar

    ( Set up as user "shell" a little )
    ( wrapper function which invokes  )
    ( the actual nanomsh shell:       )
    ::  { [] -> @ }
        ]pop 

	me$s.nanomudAvatar -> avatar
	me$s.nanomudWorld  -> world

	[   :avatar avatar
	    :world  world
	|   'nanomsh:]shell
        ]exec
    ; --> user$s.shell
;

( =====================================================================	)
( - makeDefaultWorld -- Construct a simple test world.			)

:   makeDefaultWorld { -> }

    ( Create a default world: )
    "Nanoworld" makeWorld --> nanomudVars:_world

    ( Create default user/avatar pairs: )
    [ 'z' 'z' 'n' 'a' 'n' 'o' '1' | |secureHash |secureHash ]join -> encryptedPassphrase1
    [ 'z' 'z' 'n' 'a' 'n' 'o' '2' | |secureHash |secureHash ]join -> encryptedPassphrase2
    "nano1" nanomudVars:_world encryptedPassphrase1 rootMakeNanomudUser
    "nano2" nanomudVars:_world encryptedPassphrase2 rootMakeNanomudUser

    ( Create a second room and exits both ways: )

    ( Find nursery: )
    nanomudVars:_world.nursery -> nursery

    ( Create a second room: )
    nanomudVars:_world "Rose Garden" makeRoom -> garden

    ( Describe the second room: )
    "Sun-warmed roses scent the air, "
    "only the robin in the birdbath breaks the silence." join
    --> garden.description

    ( Create an exit leading to second room: )
    nanomudVars:_world "garden"  nursery garden   makeExit

    ( Create an exit leading back to first room: )
    nanomudVars:_world "nursery" garden nursery   makeExit
;

( =====================================================================	)
( - start -- Start default world.					)

:   start { -> }

    ( Maybe create a default world.  )
    ( Note that we cannot do this at )
    ( load time because we need a    )
    ( valid nanomsh:]shell fn before )
    ( we can create avatars:         )
    nanomudVars:_world not if makeDefaultWorld fi

    ( Start up login daemon only if  )
    ( it isn't already running:      )
    nanomudVars:_world.job -> job
    t           -> needToStartDaemon
    job if
        job jobIsAlive? if
	    nil -> needToStartDaemon
    fi  fi 
    needToStartDaemon if
	nanomudVars:_world   .sys.muqPort mufVars:_nanomudPortOffset +   startMud
    fi
;

( =====================================================================	)
( - Our config entry							)

( Commented out because it's likely to confuse people			)
( looking for the full mud:						)
( "Start nanomud" 'nanomud:start addConfigFn 				)


( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)


