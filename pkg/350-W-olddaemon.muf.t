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

( - 350-W-olddaemon.muf -- Generic daemon for rooms-and-exits islekit.	)
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
( - Overview -								)

( This file implements the default user daemon for the Muq		)
( oldmud.  The user daemon is responsible for activating		)
( user-owned objects -- in particular the user's avatar --		)
( in much the same way the isle daemon is responsible for		)
( activating isleOwned objects and thew isle proper.			)
(									)
( The user daemon is structurally similar to the isle daemon,		)
( but in general should be owned and maintained separately,		)
( since it represents user preferences and customizations,		)
( not those of the isle admin.						)
(									)
( It would be possible to combine the mudUser shell with the 		)
( the mudUser daemon in one big hack responding to all external	)
( messages, but it seems cleaner design to keep the userObject		)
( behavior code factored out separately from the user interface.	)
(									)
( At present, the user daemon uses by default the same actual ]daemon	)
( driver function as the isle daemon, namely oldmud:]daemon, but	)
( nothing prevents any user who wishes from using another driver,	)
( simply by setting avatar/daemonShell to the desired value.		)
(									)
( The isle daemon do, however, use entirely different sets		)
( of packet handler functions (do-*).  These are stored in		)
( the avatar/ops stack, which contains alternating keywords		)
( and genericFunction symbols						)


( =====================================================================	)
( - Package 'oldmud', exported symbols --				)

"oldmud" inPackage




( =====================================================================	)

( - Functions -								)


( =====================================================================	)
( - gripe -- Called by default methods of packet-handler generics	)

:   gripe { [] $ -> [] }

    -> fn

    |length pop ( Just to keep the arity checker happy. )

"Mo method for: " fn toString join "\n" join debugPrint

(    "Unsupported argument type combination:" -> tx )
( )
(    |shift -> he )
(    |shift -> to )
(    |shift -> av )
(    |shift -> id )
(    |shift -> a0 )
(    |shift -> a1 )
(    |shift -> a2 )
(    [ "%s: %s %s %s %s %s %s %s %s\n" )
(	fn  tx he to av id a0 a1 a2 )
(    | ]print  debugPrint )
;
'gripe export





( =====================================================================	)
( - makeDaemonIo -- Allocate stdin/stdout pair for a live object.	)

:   makeDaemonIo { -> $ }

    makeBidirectionalMessageStream
    -> standardInput
    -> standardOutput

    ( Set input so folks can write into it. )
    t --> standardOutput.allowWrites

    standardOutput
;



( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - daemonHome -- Mixin for places daemons are spawned from.		)

( 'daemonHome' contains the information needed to start		)
( a daemon running.							)
(									)
( DAEMON-SHELL is the actual function to EXEC.				)
(									)
( DAEMON-JOB will be the actual running job -- having a pointer		)
(    to it simplifies checking to see if it is dead &tc.		)
(									)
( DAEMON-TASK is the state record for the daemon's delayed-		)
(    execution facility.  Making this a subrecord rather than		)
(    a mixin facilitates changing implementations without		)
(    recompiling the daemon, if desired.				)
(									)
( DAEMON-STATES and DAEMON-CLASSES hold the state records used by	)
(    daemonShell while running: They are the same length, with		)
(    daemonClass[i] holding a class instance and daemonState[i]	)
(    holding an instance of that class.  These are actually created	)
(    in ]daemon but are specified by liveClasses, which is filled in	)
(    by ENTER-OP calls in fns like ENTER-PING-SERVER-FUNCTIONS.		)
(	The basic idea here is that each daemon services many LIVE,	)
(	of many different sorts, and each of those LIVE objects may	)
(	support many different operations, each of which may need a	)
(	state record.  The LIVE objects list the ops they support,	)
(	and the daemons create the state records as needed.  The	)
(	design allows adding operations to objects at runtime, without	)
(	needing to define new classes or kill running daemons.		)

defclass: daemonHome
    :export  t

    :is 'live

    ( Override LIVE definition of IO )
    ( in order to add an initform:   )
    :slot :io	       	  :prot "rwr-r-" :initform :: makeDaemonIo ;

    :slot :daemonTask     :prot "rw----" :initform :: 'task:home makeInstance ;
    :slot :daemonAtMax    :prot "rw----" :initval  10
    :slot :daemonClasses  :prot "rw----" :initform :: makeStack ;
    :slot :daemonStates   :prot "rw----" :initform :: makeStack ;
    :slot :daemonJob	  :prot "rw----" :initval     nil
    :slot :daemonShell	  :prot "rw----" :initval ']daemon
;

( =====================================================================	)

( - Methods -								)

( =====================================================================	)
( - Overview: "req" requests to the daemon				)

( Requesting service from a daemon animating an object TO is normally	)
( done via a "req" packet delivered through its TO/IO stream.		)
( The immediate call normally looks like:				)
(									)
(       [   REQ_OP TO XX ME AV IO TASK-ID A0 A1 A2			)
(       |   "req" t TO/IO						)
(	    |maybeWriteStreamPacket					)
(	    pop pop							)
(       ]pop								)
(									)
( where									)
(     REQ_OP  is one of the REQ-* opcodes defined in 330-W-OLDMUD.T	)
(     TO      is the LIVE mud object to which the request is directed	)
(     XX      is currently unused and clobbered?  Ick.			)
(     AV      is the avatar taking responsibility for this request,	)
(	      which should be notified of any problems &tc.		)
(     TASK-ID is the local continuation which will process the reply,	)
(	      issued by the local TASK facility in response to an	)
(	      TASK:TASK request, or a wrapper around such a request,	)
(	      such as an TASK:IO-DO, TASK:DO or TASK:IN-DO.	)
(     A0      An arbitrary argument, meaning dependent upon the		)
(             specific REQ_OP used.					)
(     A1      "                                                "	)
(     A2      "                                                "	)
(									)
( NOTE: If TO is remote, and you are making a number of requests to	)
( it, you will often want to save the value of TO/IO locally, to	)
( avoid an extra network round trip each time to fetch it.		)
(									)
( The daemon processes a "req" packet as follows:			)
(									)
(    1) It silently discards the packet if it looks broken, e.g.:	)
(       If REQ_OP is not an integer, or not in its list of known ops.	)
(       If the TO object is not local to the daemon's machine.		)
(       If the TO object is not owned by the daemon's owner.		)
(       If the TO object is not LIVE.					)
(									)
(    2) It fetches its state record IT for this REQ_OP.			)
(       Each daemon has a separate state record for			)
(       each supported operation.  This makes it easy to		)
(       add new operations, at runtime if desired, without		)
(       needing to restart the daemon or recompile any central		)
(       resources such as the daemon or its state record.		)
(									)
(    3) It fetches its requestHandler function FN for this		)
(       REQ_OP.  Again, each operation is handled by a separate		)
(       function (which may of course be generic if desired), in	)
(       the interests of keeping the implementation well-factored.	)
(									)
(    4) It changes the first three arguments of the argblock to be	)
(	TO   The recipient object, as before.  Making it first		)
(	     makes it as easy as possible for FN to be a generic	)
(	     functions specializing on TO.				)
(	IT   The state record for this operation in this daemon.	)
(	WHO  Entity authorizing the request, as supplied by the special	)
(            |readAnyStreamPacket 'who' return value.  In a single	)
(	     server environment, this provides some authentication;	)
(	     in a distributed environment, currently not.		)
(									)
(    5) It then invokes FN on the updated argblock, which will thus	)
(	look like:							)
(									)
(       TO      is the LIVE mud object to which the request is directed	)
(       IT      state record for this operation.			)
(       AV      is the avatar taking responsibility			)
(       TASK-ID is the local continuation which will process the reply,	)
(	        issued by the local TASK facility in response to an	)
(	        TASK:TASK request or a wrapper around such a request.	)
(       A0      An arbitrary argument, meaning dependent upon the	)
(               specific REQ_OP used.					)
(       A1      "                                                "	)
(       A2      "                                                "	)
(									)
( FN is arbitrary user code handling the request, and hence can do	)
( anything it wants, ranging from nothing at all (ignoring		)
( unwanted requests is quite kosher) to recursively generating		)
( a cascade of other requests.  It will, however, typically		)
( at some point acknowledge the request by sending an "ack"		)
( packet to IO with the specified TASK-ID:				)
(									)
(       [   TASK-ID POSSIBLE-OTHER-ARGS					)
(       |   "ack" t IO							)
(	    |maybeWriteStreamPacket					)
(	    pop pop							)
(       ]pop								)
(									)
( The daemon processes an "ack" packet as follows:			)
( 									)
(    1) It silently discards the packet if no continuation 		)
(	matching TASK-ID is currently registered with it.		)
(									)
(    2) It looks up the corresponding continuation function CONT-FN	)
(									)
(    3) It invokes CONT-FN with an argblock consisting of:		)
(       TASK-ID								)
(	    CONT-FN typically uses this to de-register this task,	)
(	    after verifying that the ack packet doesn't look like	)
(	    a spoof.							)
(	ARG0 ARG1 ... arguments originally given to IO-DO.		)
(	    Since these arguments are stored locally, they provide	)
(	    state storage more trustworthy than values returned in	)
(	    the "ack" packet.						)
(	POSSIBLE-OTHER-ARGS						)
(	    These values were returned in the "ack" package, and	)
(	    may contain arbitrary values with interpretation		)
(	    depending on the specific original REQ_OP:  For example,	)
(	    if REQ_OP was a "look" type request, these may be a block	)
(	    of chars containing a textual description of TO.		)
(									)
( CONT-FN proper is again arbitrary user code outside the control of	)
( the daemon proper;  It will normally echo some indication of success	)
( back to the user shell (if one is running), at least if the request	)
( was explicitly initiated by the user.					)


( =====================================================================	)

( - More non-generic functions -					)

( =====================================================================	)
( - userServerUpdateTask -- 						)

:   userServerUpdateTask { [] -> [] }
    |shift -> taskId
    |shift -> why	( text name	)
    ]pop    

    ( Don't attempt to update missing location servers: )
    me$s.userServer1 not if nil --> me$s.userServer1NeedsUpdating fi
    me$s.userServer2 not if nil --> me$s.userServer2NeedsUpdating fi
    me$s.userServer3 not if nil --> me$s.userServer3NeedsUpdating fi
    me$s.userServer4 not if nil --> me$s.userServer4NeedsUpdating fi

    ( Tell all out of date servers our current location: )
    [ |
        me$s.userServer1NeedsUpdating if me$s.userServer1 |push fi
        me$s.userServer2NeedsUpdating if me$s.userServer2 |push fi
        me$s.userServer3NeedsUpdating if me$s.userServer3 |push fi
        me$s.userServer4NeedsUpdating if me$s.userServer4 |push fi
	|for outOfDateServer do{
	    outOfDateServer taskId me$s.ioStream muqnet:sendSetUserInfo
	}
	|length 0 != if
	    ( Schedule another repeat of us to execute: )
	    1000 -> delayTime
	    [ @.task delayTime taskId why 'userServerUpdateTask | task:inDo ]pop
	fi
    ]pop

    [ |
;

( =====================================================================	)
( - startUserServerUpdateTask -- support for handleDaemonIpPortChanges	)

:   startUserServerUpdateTask { -> }

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
    10000 -> delayTime
    nil   -> taskId

    [ @.task delayTime taskId "userServerUpdate" 'userServerUpdateTask | task:inDo ]pop
;

( =====================================================================	)
( - handleDaemonIpPortChanges -- Compare vs .sys values.		)

:   handleDaemonIpPortChanges { -> }

    ( Has server address changed? )
    .sys.ip0     me$s.ip0  !=
    .sys.ip1     me$s.ip1  != or
    .sys.ip2     me$s.ip2  != or
    .sys.ip3     me$s.ip3  != or
    .sys.muqPort me$s.port != or -> ipPortHasChanged
    
    ( If server address has changed... )
    ipPortHasChanged if

        ( ... then remember our new ip address ... )
	.sys.ip0     --> me$s.ip0
	.sys.ip1     --> me$s.ip1
	.sys.ip2     --> me$s.ip2
	.sys.ip3     --> me$s.ip3
	.sys.muqPort --> me$s.port
	++ me$s.userVersion

        ( ... and remember to notify our location servers: )
	0 --> me$s.userServer1NeedsUpdating
	0 --> me$s.userServer2NeedsUpdating
	0 --> me$s.userServer3NeedsUpdating
	0 --> me$s.userServer4NeedsUpdating
	startUserServerUpdateTask
    fi
;


( =====================================================================	)
( - ]daemon -- Default daemon to animate object(s).			)

:   ]daemon { [] -> ? }

    ( Process argblock: )
	:home |get -> home
    ]pop
    [ "oldmud:]daemon: starting up for %s as %s, home %s" me @ home | ]logPrint
(    [ "oldmud:]daemon %s %s: server0=%s" me @ me$s.userServer0 | ]logPrint )
(    [ "oldmud:]daemon %s %s: server1=%s" me @ me$s.userServer1 | ]logPrint )
(    [ "oldmud:]daemon %s %s: server2=%s" me @ me$s.userServer2 | ]logPrint )
(    [ "oldmud:]daemon %s %s: server3=%s" me @ me$s.userServer3 | ]logPrint )
(    [ "oldmud:]daemon %s %s: server4=%s" me @ me$s.userServer4 | ]logPrint )

    @ --> home.daemonJob
    @ --> home.daemonTask.taskJob
    home.daemonClasses	-> dc
    home.daemonStates	-> ds
    home.daemonTask --> @.task
    home            --> home.daemonTask.taskState

    ( Find/create table of users gagged by our user: )
    me$s.gagged -> gagged
    gagged index? not if
	makeHash   -> gagged
	gagged    --> me$s.gagged
    fi

    ( Write error msgs to logfile, but don't echo them )
    ( to stdout, since nobody is reading it anyhow:    )
    'muf:logEvent --> @.reportEvent

    ( Get stream to read from: )
    @.standardInput -> mss
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/iii\n" d, )
    mss isAMessageStream
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/jjj\n" d, )
    @.actingUser    -> self
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/kkk\n" d, )

    ( Save stream in user record where    )
    ( muqnet logic can find it:           )
    mss --> self$s.ioStream
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon starting up, ioStream " d, mss d, "\n" d, )

    ( What follows is a quickly stripped  )
    ( down version of the standard shell  )
    ( boilerplate.  Some of it may not    )
    ( make much sense in this context.    )

    ( Establish a restart letting users   )
    ( to kill the job from the debugger:  )
    [   :function :: { -> ! } nil endJob ;
        :name 'endJob
        :reportFunction "Terminate job."
    | ]withRestartDo{               ( 1 )
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/lll\n" d, )

    ( Establish a handler letting users   )
    ( terminate a job with a signal       )
    ( -- via 'killJob' say:              )
    [ .e.kill :: { [] -> [] ! } :why |get endJob ;
    | ]withHandlerDo{               ( 2 )
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/mmm\n" d, )

    ( Establish a restart letting users   )
    ( return to the main shell prompt     )
    ( from the debugger:                  )
    [   :function :: { -> ! }  'abrt goto ;
	:name 'abort
	:reportFunction "Return to main mufShell prompt."
    | ]withRestartDo{               ( 3 )
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/nnn\n" d, )

    ( Establish a handler letting users   )
    ( abort a job with a signal           )
    ( -- via 'abortJob' say:             )
    [ .e.abort :: { [] -> [] ! } 'abort invokeRestart ;
    | ]withHandlerDo{               ( 4 )
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/ooo\n" d, )

    ( Establish a handler that will kill  )
    ( us if we lose the net link:         )
    [ .e.brokenPipeWarning :: { [] -> [] ! } nil endJob ;
    | ]withHandlerDo{               ( 5 )
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/ppp\n" d, )


    ( Establish a handler that will dump  )
    ( us into debugger on .etc.debug:     )
    [ .e.debug :: { [] -> [] ! } "" break ;
    | ]withHandlerDo{               ( 7 )
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/qqq\n" d, )

    ( We don't want errors throwing )
    ( us into the debugger:         )
    nil --> @.breakEnable
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/rrr\n" d, )
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon: PID = " d, @.pid d, "\n" d, )

    ( Has IP:port of our server changed? )
    handleDaemonIpPortChanges

    "oldmud:daemon: starting up.\n" log,
    withTags abrt exitShell do{ ( 8 ) ( Trap compile errs etc    )
    abrt                          ( Continuation from errors )
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/sss =====> ERROR TRAPPED <===== \n" d, )

    ( Central event loop: )
    do{
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon.ttt (luptop)\n" d, )
	( Maybe do some pending operations: )
	[ home.daemonTask home.daemonAtMax | task:runSomePendingTasks ]pop
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/uuu\n" d, )

	( Figure how long we can sleep: )
	[ home.daemonTask | task:timeUntilNextTask ]-> sleepTime
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/vvv SLEEPTIME = " d, sleepTime d, "\n" d, )

	[ mss | t sleepTime |readAnyStreamPacket
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/www\n" d, )
	    -> stream
	    -> who
	    -> tag
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon read a packet, stream = " d, stream d, " who = " d, who d, " tag = " d, tag d, "\n" d, )

	    ( Ignore/refuse packets from gagged players: )
	    gagged who get? pop if
		( tag case{  )
		( on: "req"  )
		    ( Maybe should fire back "ack" packet )
		    ( here, with err value of "ban"?      )
		( } )
		]pop loopNext
	    fi

	    ( Ignore packet types other )
            ( than "req"/"one"/"ack":   )
	    tag case{ 

	    on: "req"
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/req\n" d, )
		( Fall through to logic below case{} statement. )

	    on: "ack"
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/ack\n" d, )
		( Handling an "ack" packet.                )
		( If 'id' is an integer, treat packet as a )
		( continuation for execution by TASK:	   )
		|first -> id
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/ack: seq = " d, id d, "\n" d, )
		id integer? not if ]pop loopNext fi
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/ack: home.daemonTask = " d, home.daemonTask d, "\n" d, )
		who              |unshift    
		home.daemonTask  |unshift    
( .sys.muqPort d, "(350)<" d, @ d, ">daemon/ack runIoTask argblock is:\n" d, )
( |for val iii do{ .sys.muqPort toString "(350) #" join iii toString join ": " join val toString join "\n" join d, } )
( .sys.muqPort d, "(350)<" d, @ d, ">daemon/ack done listing runIoTask argblock\n" d, )
		task:runIoTask
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/ack COMPLETED ACK PROCESSING\n" d, )
		]pop loopNext

	    on: "one"
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/one\n" d, )
		( Only our player is entitled to ask us to initiate a req: )
		who me != if ]pop loopNext fi

	    else:
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon/???\n" d, )
                ]pop loopNext
	    }

	    ( Unpack standard packet fields: )
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon: |length = " d, |length d, "\n" d, )
	    |length 8 <            if  ]pop loopNext  fi
	    0 |dupNth -> op
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon: op = " d, op d, "\n" d, )
	    1 |dupNth -> me
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon: me = " d, me d, "\n" d, )
	(   2 |dupNth -> xx )
	    3 |dupNth -> av
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon: av = " d, av d, "\n" d, )
	    4 |dupNth -> id
( .sys.muqPort d, "(350)<" d, @ d, ">oldmud:daemon: id = " d, id d, "\n" d, )
	(   5 |dupNth -> a0 )
	(   6 |dupNth -> a1 )
	(   7 |dupNth -> a2 )

	    ( Ignore packets broken in various ways: )
	    me   live? not           if ]pop loopNext fi
	    me$s.owner self    !=    if ]pop loopNext fi
	    op integer? not          if ]pop loopNext fi

	    ( Fetch our driving info from 'me': )
	    me.liveNames   -> opn     opn isAStack
	    me.liveFns     -> opf     opf isAStack
	    me.liveClasses -> opc     opc isAStack

	    ( Punt if we don't support this operation: )
	    opn op getKey? -> i not if
		]pop loopNext
	    fi

	    ( Fetch/create state record IT for this operation: )
	    opc[i] -> c
	    c if
		dc c getKey? -> j not if
		    c makeInstance ds push
		    c               dc push
		    dc c getKey? -> j pop
		fi
		ds[j] -> it
	    else
		nil -> it
	    fi

	    ( Make recipient object first arg, 'cause that's the easiest )
	    ( arg to specialize on.  Make the state the second arg. The  )
	    ( 'who' becomes third arg.  'op' gets dropped:               )
	    me  0 |setNth
	    it  1 |setNth
	    who 2 |setNth

	    ( Invoke requested operation: )
( .sys.muqPort d, "(350)<" d, @ d, ">daemon ready for operation " d, opf[i] d, " ...\n" d, )
( .sys.muqPort toString "(350)<" d, @ d, ">daemon operation argblock is:\n" join d, )
( |for val iii do{ .sys.muqPort toString "(350) #" join iii toString join ": " join val toString join "\n" join d, } )
( .sys.muqPort d, "(350)<" d, @ d, ">daemon INVOKING operation " d, opf[i] d, " ...\n" d, )
	    opf[i] symbolFunction call{ [] -> [] }
( .sys.muqPort d, "(350)<" d, @ d, ">daemon back from operation " d, opf[i] d, "\n" d, )

	    ( Maybe fire back "ack" packet: )
	    |length 0 > if
		me |unshift
		id |unshift
		"ack" t av
		|maybeWriteStreamPacket
		pop pop
	    fi
	]pop
    }

    exitShell
    "oldmud:daemon: exiting.\n" log,
    } ( 8 )
    } ( 7 )
    } ( 5 )
    } ( 4 )
    } ( 3 )
    } ( 2 )
    } ( 1 )
;
']daemon export



( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

