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

( - 347-W-oldrequest.muf -- Asynchronous rpc built on task facility.	)
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
( Created:      97Aug12							)
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
( - Quip								)

( 	Sanity is its own punishment.					)

( =====================================================================	)
( - Overview -								)

( This file implements delayed execution support for daemons,		)
( vaguely in the spirit of the unix 'at' command:  The user		)
( may specify a function, up to ten arguments, and a time at		)
( which that function should be invoked on those arguments.		)
( We attempt to ensure that the function is eventually so invoked,	)
( and not before the given time.					)
(									)
( The current implementation is a very simple one, intended for		)
( relatively light use;  A heavy duty implemention handling large	)
( numbers of events would need to implement a serious modern priority	)
( queue instead of just using unsorted stacks.				)
(									)
( As support for distributed processing, an IO-DO function is also	)
( supported.  The intention here is to support an asynchronous		)
( request to another daemon, where we want to execute a given IOFN	)
( function when the reply is recieved, and to timeout after some	)
( number of seconds, optionally executing an alternate FN function	)
( at that point (which might, say, report the timeout to the user).	)
(									)
( In this scenario, the typical	code cliche would be to first queue	)
( up the two function calls via IO-DO, getting back an integer task	)
( ID in return, then to send the actual request with the IT argument	)
( set to the given ID.  When the daemon sees an incoming reply with	)
( IT set to an integer, it will invoke the appropriate task IOFN,	)
( and with the given packet as arguments, prepending to the packet	)
( the task id and the queued arguments.					)
(									)
( Note that task does NOT delete the task from the task queue when	)
( invoking an IOFN.  This is to reduce the danger of other users	)
( accidentally or maliciously deleting tasks by shipping us bogus	)
( IT values.  The IOFN should check that the given packet is as		)
( expected, then delete the task itself using ASYNCH:KILL-TASK. In some	)
( cases, where multiple incoming requests are to be handled by the	)
( same task, the task may in fact be left in the task queue.		)




( =====================================================================	)
( - Package 'task' --							)

"task" inPackage

( =====================================================================	)
( - requestIoFn -- Support fn for TASK:]REQUEST.			)

:   requestIoFn { [] -> [] }
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn/aaa\n" d, )
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn argblock is:\n" d, )
( |for val iii do{ .sys.muqPort d, "(347) #" d, iii d, ": " d, val d, "\n" d, } )
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn done listing argblock\n" d, )

    |shift -> taskId		( From task:runIoTask		)
    |shift -> from		( From task:runIoTask		)
    |shift -> fa		( fa				)
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn fa = " d, fa d, "\n" d, )
    |shift -> args		( args				)
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn args = " d, args d, "\n" d, )
    |shift -> fn		( fn				)
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn fn = " d, fn d, "\n" d, )
    |shift -> to		( to				)
    |shift -> arg0		( arg0				)
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn arg0 = " d, arg0 d, "\n" d, )
    |shift -> arg1		( arg1				)
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn arg1 = " d, arg1 d, "\n" d, )
    |shift -> arg2		( arg2				)
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn arg2 = " d, arg2 d, "\n" d, )
    |shift -> he		( Return val 			)
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn from = " d, from d, "\n" d, )
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn to   = " d, to   d, "\n" d, )
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn he   = " d, he   d, "\n" d, )

    ( Check that we -did- call this object: )
    to he != if
        ]pop [ | return
    fi

    ( Kill the timeout task: )
    [ @.task taskId | task:killTask ]pop

    ( Invoke user-supplied iofn: ) 
    fn if
	args 2 > if arg2 |unshift fi
	args 1 > if arg1 |unshift fi
	args 0 > if arg0 |unshift fi
	to     |unshift 
	from   |unshift 
	taskId |unshift 
	fa if fa |unshift fi
	fn call{ [] -> [] }
    fi
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestIoFn/zzz\n" d, )
;
'requestIoFn export

( =====================================================================	)
( - requestTimeoutFn -- Support fn for TASK:]REQUEST.			)

:   requestTimeoutFn { [] -> [] }
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestTimeoutFn/aaa\n" d, )
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestTimeoutFn argblock is:\n" d, )
( |for val iii do{ .sys.muqPort d, "(347) #" d, iii d, ": " d, val d, "\n" d, } )
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestTimeoutFn done listing argblock\n" d, )
    |shift -> taskId		( From task:runSomePendingTasks	)
    |shift -> why		( From task:runSomePendingTasks	)
    |shift -> who		( From task:runSomePendingTasks	)
    |shift -> tries		( targ0					)
    |shift -> delay		( targ1					)
    |shift -> am		( targ2					)
    |shift -> errfn		( targ3					)
    |shift -> op		( targ4					)
( [ "]requestTimeoutFn/aaa op=%s taskId=%d delay=%d" op taskId delay | ]print log, )
    |shift -> fa		(  arg0					)
    |shift -> args		(  arg1					)
    |shift -> fn		(  arg2					)
    |shift -> to		(  arg3					)
    |shift -> a0		(  arg4					)
    |shift -> a1		(  arg5					)
    |shift -> a2		(  arg6					)
    ]pop

    @.task.taskState -> av

    tries 0 <= if
	errfn if
	    ( Invoke user-supplied errfn: ) 
	    [ |
		args 2 > if a2 |unshift fi
		args 1 > if a1 |unshift fi
		args 0 > if a0 |unshift fi
		to      |unshift 
		taskId |unshift 
		fa if fa |unshift fi
		errfn call{ [] -> [] }
	    ]pop
	else
	    ( Send timeout report to user shell: )
	    av :userIo get? -> uio if	( Isle daemons don't have user shells	)
		op toString " timed out, task id = " join taskId toString join
		am if "   " join am toString join fi
		vals[
		    "eko" t uio
		    |maybeWriteStreamPacket
		    pop pop
		]pop
	    fi
	fi
    else

        ( op toString " no response retrying:  task id " join taskId toString join oldmud:echo )
	[ "task:requestTimeoutFn %s no response, retrying: task id %s\n" op taskId | ]logPrint

	( Retry: )
	( Submit continuation task: )
	[   @.task		( TASK:HOME instance	)
	    delay		( when			)
	    taskId		( taskId		)
	    who			( who			)
	    why			( why			)
	    5			( targs			)
	    'requestTimeoutFn	( timeout fn		)
            'requestIoFn
	    tries 1-		( targ0 )
	    delay		( targ1 )
	    am			( targ3 )
	    errfn		( targ4 )
	    op			( targ5 )
	    fa			(  arg0 )
	    args		(  arg1 )
	    fn			(  arg2 )
	    to			(  arg3 )
	    a0			(  arg4 )
	    a1			(  arg5 )
	    a2			(  arg6 )
	| task:ioDo ]-> taskId
	[ @.task.taskState | oldmud:doNop ]pop

	( Send request: )
	op symbol? if op symbolValue -> op fi
	[   op to t av taskId a0 a1 a2
	|   "req" t to
	    |maybeWriteStreamPacket
	    pop pop
	]pop
    fi

    [ |
( .sys.muqPort d, "(347)<" d, @ d, "> ]requestTimeoutFn/zzz\n" d, )
;
'requestTimeoutFn export

( =====================================================================	)
( - ]request -- Send an asynchronous request.				)

:   ]request { [] -> }
( .sys.muqPort d, "(347)<" d, @ d, "> ]request/aaa\n" d, )
( .sys.muqPort d, "(347)<" d, @ d, "> ]request argblock is:\n" d, )
( |for val iii do{ .sys.muqPort d, "(347) #" d, iii d, ": " d, val d, "\n" d, } )
( .sys.muqPort d, "(347)<" d, @ d, "> ]request done listing argblock\n" d, )
    :errFn   nil |gep -> errfn
( .sys.muqPort d, "(347)<" d, @ d, "> ]request errfn = " d, errfn d, "\n" d, )
    :fn      nil |gep -> iofn
( .sys.muqPort d, "(347)<" d, @ d, "> ]request iofn = " d, iofn d, "\n" d, )
    :fa      nil |gep -> fa
( .sys.muqPort d, "(347)<" d, @ d, "> ]request fa = " d, fa d, "\n" d, )
    :am "dunno"  |gep -> am
( .sys.muqPort d, "(347)<" d, @ d, "> ]request am = " d, am d, "\n" d, )
    :op      nil |gep -> op
( .sys.muqPort d, "(347)<" d, @ d, "> ]request op = " d, op d, "\n" d, )
    :to      nil |gep -> to
( .sys.muqPort d, "(347)<" d, @ d, "> ]request to = " d, to d, "\n" d, )
    :a0      nil |gep -> a0
( .sys.muqPort d, "(347)<" d, @ d, "> ]request a0 = " d, a0 d, "\n" d, )
    :a1      nil |gep -> a1
( .sys.muqPort d, "(347)<" d, @ d, "> ]request a1 = " d, a1 d, "\n" d, )
    :a2      nil |gep -> a2
( .sys.muqPort d, "(347)<" d, @ d, "> ]request a2 = " d, a2 d, "\n" d, )
    :a3      nil |gep -> a3
( .sys.muqPort d, "(347)<" d, @ d, "> ]request a3 = " d, a3 d, "\n" d, )
    :delay   nil |gep -> delay
( .sys.muqPort d, "(347)<" d, @ d, "> ]request delay = " d, delay d, "\n" d, )
    :retries nil |gep -> retries
( .sys.muqPort d, "(347)<" d, @ d, "> ]request retries = " d, retries d, "\n" d, )
    :taskId nil |gep -> taskId
( .sys.muqPort d, "(347)<" d, @ d, "> ]request taskId = " d, taskId d, "\n" d, )
    :av      nil |gep -> av	( Buggo, this aren't saved for retry as yet.	)
( .sys.muqPort d, "(347)<" d, @ d, "> ]request av = " d, av d, "\n" d, )
    |length 0 != if "task:]request unrecognized keyword argument" simpleError fi
    ]pop
 
    iofn symbol? not if
        iofn callable? not if
            "task:]request iofn arg must be a callable value" simpleError
    fi  fi

    op not if "task:]request needs an :OP argument" simpleError fi
    to not if "task:]request needs a :TO argument"  simpleError fi
    op symbol? not if
        op integer? not if
            "task:]request third arg be a REQ-op integer or 'REQ-op symbol" simpleError
    fi  fi

    delay   integer? not if @.task.taskDelay   -> delay   fi
    retries integer? not if @.task.taskRetries -> retries fi

    av    not if @.task.taskState -> av    fi

    0 -> args
    a0 if 1 -> args fi
    a1 if 2 -> args fi
    a2 if 3 -> args fi
    a3 if "task:]request: :a3 currently not supported" simpleError fi
	
    ( Submit continuation task: )
    [   @.task		( TASK:HOME instance	)
	delay			( when			)
	taskId			( taskId		)
	to			( who			)
	am			( why			)
        5			( targs			)
	'requestTimeoutFn	( timeout fn		)
        'requestIoFn		( io fn			)
	retries			( targ0 )
	delay			( targ1 )
	am			( targ2 )
	errfn			( targ3 )
	op			( targ4 )
	fa			(  arg0 )
	args			(  arg1 )
	iofn			(  arg2 )
	to			(  arg3 )
        a0			(  arg4 )
        a1			(  arg5 )
        a2			(  arg6 )
    | task:ioDo ]-> taskId
( [ "]request/aaa op=%s taskId=%d delay=%d" op taskId delay | ]print log, )
    [ @.task.taskState | oldmud:doNop ]pop

    ( Send request: )
    op symbol? if op symbolValue -> op fi
    [   op to t av taskId a0 a1 a2
    |   "req" t to
	|maybeWriteStreamPacket
	pop pop
    ]pop
( .sys.muqPort d, "(347)<" d, @ d, "> ]request/zzz\n" d, )
;
']request export

"oldmud"  inPackage
'task:]request import

"oldmsh"  inPackage
'task:]request import

"task" inPackage

( --------------------------------------------------------------------- )
( - Special-case ]request versions					)

( The following are specialCase versions of ]request used		)
( to talk directly to some remote Muq muqnet daemon, as opposed		)
( to talking to some object within a remote Muq server via the		)
( the muqnet daemon.  We use them for bootstrapping, since we		)
( start out not having pointers to any objects within the remote	)
( Muq server.								)

( =====================================================================	)
( - requestMuqnetIslesIoFn -- Support fn.				)

:   requestMuqnetIslesIoFn { [] -> [] }
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetIslesIoFn/aaa\n" d, )
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetIslesIoFn argblock is:\n" d, )
( |for val iii do{ .sys.muqPort d, "(347) #" d, iii d, ": " d, val d, "\n" d, } )
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetIslesIoFn done listing argblock\n" d, )

    |shift -> taskId		( From task:runIoTask		)
    |shift -> from		( from				)
    |shift -> fa		( fa				)
    |shift -> fn		( fn				)
    |shift -> to		( to				)

    ( Check that we -did- call this object: )
(    to he != if )
(        ]pop [ | return )
(    fi )

    ( Kill the timeout task: )
    [ @.task taskId | task:killTask ]pop

    ( Invoke user-supplied iofn: ) 
    fn if
	from     |unshift 
	taskId   |unshift 
	fa if fa |unshift fi
	fn call{ [] -> [] }
    fi
    ]pop

    [ |
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetIslesIoFn/zzz\n" d, )
;
'requestMuqnetIslesIoFn export

( =====================================================================	)
( - requestMuqnetIslesTimeoutFn -- Support fn.				)

:   requestMuqnetIslesTimeoutFn { [] -> [] }
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetIslesTimeoutFn/aaa\n" d, )
    |shift -> taskId		( From task:runSomePendingTasks	)
    |shift -> tries		( targ0					)
    |shift -> delay		( targ1					)
    |shift -> am		( targ2					)
    |shift -> errfn		( targ3					)
    |shift -> fa		(  arg0					)
    |shift -> iofn		(  arg1					)
    |shift -> to		(  arg2					)
    ]pop

    @.task.taskState -> av

    tries 0 <= if
	( Send timeout report to user shell: )
	av :userIo get? -> uio if	( Isle daemons don't have user shells	)
	    "muqnetIsles timed out, task id = " taskId toString join vals[
		"eko" t uio
		|maybeWriteStreamPacket
		pop pop
	    ]pop
	fi
    else
        "muqnetIsles no response retrying:  task id " taskId toString join oldmud:echo

	( Retry: )
	( Submit continuation task: )
	[   @.task		( TASK:HOME instance	)
	    delay		( when			)
	    taskId		( taskId		)
	    nil			( who			)
	    nil			( why			)
	    4			( targs			)
	    'requestMuqnetIslesTimeoutFn	( timeout fn		)
            'requestMuqnetIslesIoFn
	    tries 1-		( targ0 )
	    delay		( targ1 )
	    am			( targ3 )
	    errfn		( targ4 )
	    fa			(  arg0 )
	    iofn		(  arg1 )
	    to			(  arg2 )
	| task:ioDo ]-> taskId
	[ @.task.taskState | oldmud:doNop ]pop

	( Send request: )
	[   @.task.taskState.io to taskId | muqnet:sendIsles ]pop
    fi

    [ |
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetIslesTimeoutFn/zzz\n" d, )
;
'requestMuqnetIslesTimeoutFn export

( =====================================================================	)
( - ]requestMuqnetIsles -- Ask how many isles some Muq server has.	)

:   ]requestMuqnetIsles { [] -> }

    ( Sanity checks: )
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetIsles/aaa\n" d, )

    :errFn   nil |gep -> errfn
    :fn      nil |gep -> iofn
    :fa      nil |gep -> fa
    :am      nil |gep -> am
    :to      nil |gep -> to
    :delay   nil |gep -> delay
    :retries nil |gep -> retries
    :taskId nil |gep -> taskId
    |length 0 != if "task:]requestMuqnetIsles unrecognized keyword argument" simpleError fi
    ]pop
 
    to guest? not if
        "task:]requestMuqnetIsles :to arg must be a Guest" simpleError
    fi
    
    iofn symbol? not if
        iofn callable? not if
            "task:]requestMuqnetIsles iofn arg must be a callable value" simpleError
    fi  fi

    delay   integer? not if @.task.taskDelay   -> delay   fi
    retries integer? not if @.task.taskRetries -> retries fi

    ( Submit continuation task: )
    [   @.task		( TASK:HOME instance	)
	delay			( when			)
	taskId			( taskId		)
	nil			( who			)
	nil			( why			)
        4			( targs			)
	'requestMuqnetIslesTimeoutFn	( timeout fn		)
        'requestMuqnetIslesIoFn		( io fn			)
	retries			( targ0 )
	delay			( targ1 )
	am			( targ2 )
	errfn			( targ3 )
	fa			(  arg0 )
	iofn			(  arg1 )
	to			(  arg2 )
    | task:ioDo ]-> taskId
    [ @.task.taskState | oldmud:doNop ]pop

    ( Send request: )
    [   @.task.taskState.io to taskId | muqnet:sendIsles ]pop
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetIsles/zzz\n" d, )
;
']requestMuqnetIsles export

"oldmud"  inPackage
'task:]requestMuqnetIsles import

"oldmsh"  inPackage
'task:]requestMuqnetIsles import

"task" inPackage

( =====================================================================	)
( - requestMuqnetIsleIoFn -- Support fn.				)

:   requestMuqnetIsleIoFn { [] -> [] }
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetISLEIoFn/aaa\n" d, )

( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn argblock is:\n" d, )
( |for val iii do{ .sys.muqPort d, "(347) #" d, iii d, ": " d, val d, "\n" d, } )
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn done listing argblock\n" d, )

    |shift -> taskId		( From task:runIoTask		)
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn taskId = " d, taskId d, "\n" d, )
    |shift -> from		( From task:runIoTask		)
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn from = " d, from d, "\n" d, )
    |shift -> fa		( fa				)
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn fa = " d, fa d, "\n" d, )
    |shift -> fn		( fn				)
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn fn = " d, fn d, "\n" d, )
    |shift -> to		( to				)
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn to = " d, to d, "\n" d, )
    |shift -> num		( index				)
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn num = " d, num d, "\n" d, )

( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn SHORTENED argblock is:\n" d, )
( |for val iii do{ .sys.muqPort d, "(347) #" d, iii d, ": " d, val d, "\n" d, } )
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn done listing argblock\n" d, )

    ( Kill the timeout task: )
    [ @.task taskId | task:killTask ]pop

    ( Invoke user-supplied iofn: ) 
    fn if
	num        |unshift 
	from       |unshift 
	taskId     |unshift 
	fa if fa   |unshift fi
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn FINAL argblock is:\n" d, )
( |for val iii do{ .sys.muqPort d, "(347)<" d, @ d, "> #" d, iii d, ": " d, val d, "\n" d, } )
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn done listing argblock\n" d, )
	fn call{ [] -> [] }
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest    ]requestMuqnetISLEIoFn back from calling user fn\n" d, )
    fi
    ]pop

    [ |
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetISLEIoFn/zzz\n" d, )
;
'requestMuqnetIsleIoFn export

( =====================================================================	)
( - requestMuqnetIsleTimeoutFn -- Support fn.				)

:   requestMuqnetIsleTimeoutFn { [] -> [] }
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetISLETimeoutFn/aaa\n" d, )
    |shift -> taskId		( From task:runSomePendingTasks	)
    |shift -> tries		( targ0					)
    |shift -> delay		( targ1					)
    |shift -> am		( targ2					)
    |shift -> errfn		( targ3					)
    |shift -> fa		(  arg0					)
    |shift -> iofn		(  arg1					)
    |shift -> to		(  arg2					)
    |shift -> num		(  arg3					)
    ]pop

    @.task.taskState -> av

    tries 0 <= if
	( Send timeout report to user shell: )
	av :userIo get? -> uio if	( Isle daemons don't have user shells	)
	    "muqnetIsle timed out, task id = " taskId toString join vals[
		"eko" t uio
		|maybeWriteStreamPacket
		pop pop
	    ]pop
	fi
    else
        "muqnetIsle no response retrying:  task id " taskId toString join oldmud:echo

	( Retry: )
	( Submit continuation task: )
	[   @.task		( TASK:HOME instance	)
	    delay		( when			)
	    taskId		( taskId		)
	    nil			( who			)
	    nil			( why			)
	    4			( targs			)
	    'requestMuqnetIsleTimeoutFn	( timeout fn		)
            'requestMuqnetIsleIoFn
	    tries 1-		( targ0 )
	    delay		( targ1 )
	    am			( targ3 )
	    errfn		( targ4 )
	    fa			(  arg0 )
	    iofn		(  arg1 )
	    to			(  arg2 )
	    num			(  arg3 )
	| task:ioDo ]-> taskId
	[ @.task.taskState | oldmud:doNop ]pop

	( Send request: )
	[   @.task.taskState.io to taskId num | muqnet:sendIsle ]pop
    fi

    [ |
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetISLETimeoutFn/zzz\n" d, )
;
'requestMuqnetIsleTimeoutFn export

( =====================================================================	)
( - ]requestMuqnetIsle -- Ask for info on some Muq server isle.		)

:   ]requestMuqnetIsle { [] -> }

( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetISLE/aaa\n" d, )
    ( Sanity checks: )

    :errFn   nil |gep -> errfn
    :fn      nil |gep -> iofn
    :fa      nil |gep -> fa
    :am      nil |gep -> am
    :index     0 |gep -> num
    :to      nil |gep -> to
    :delay   nil |gep -> delay
    :retries nil |gep -> retries
    :taskId nil |gep -> taskId
    |length 0 != if "task:]requestMuqnetIsle unrecognized keyword argument" simpleError fi
    ]pop
 
    to guest? not if
        "task:]requestMuqnetIsle :to arg must be a Guest" simpleError
    fi
    
    iofn symbol? not if
        iofn callable? not if
            "task:]requestMuqnetIsle iofn arg must be a callable value" simpleError
    fi  fi

    delay   integer? not if @.task.taskDelay   -> delay   fi
    retries integer? not if @.task.taskRetries -> retries fi

    ( Submit continuation task: )
    [   @.task		( TASK:HOME instance	)
	delay			( when			)
	taskId			( taskId		)
	nil			( who			)
	nil			( why			)
        4			( targs			)
	'requestMuqnetIsleTimeoutFn	( timeout fn		)
        'requestMuqnetIsleIoFn		( io fn			)
	retries			( targ0 )
	delay			( targ1 )
	am			( targ2 )
	errfn			( targ3 )
	fa			(  arg0 )
	iofn			(  arg1 )
	to			(  arg2 )
        num			(  arg3 )
    | task:ioDo ]-> taskId
    [ @.task.taskState | oldmud:doNop ]pop

    ( Send request: )
    [   @.task.taskState.io to taskId num | muqnet:sendIsle ]pop
( .sys.muqPort d, "(347)<" d, @ d, ">oldrequest... ]requestMuqnetISLE/zzz\n" d, )
;
']requestMuqnetIsle export

"oldmud"  inPackage
'task:]requestMuqnetIsle import

"oldmsh"  inPackage
'task:]requestMuqnetIsle import

"task" inPackage

( =====================================================================	)
( - requestGetMuqnetUserIoFn -- Support fn.				)

:   requestGetMuqnetUserIoFn { [] -> [] }
( .sys.muqPort d, "(347)<" d, @ d, ">requestGetMuqnetUserIoFn/aaa\n" d, )

    |shift -> taskId		( From task:runIoTask		)
    |shift -> from		( From task:runIoTask		)
    |shift -> fa		( fa				)
    |shift -> fn		( fn				)
    |shift -> ip0		( ip0				)
    |shift -> ip1		( arg0				)
    |shift -> ip2		( arg1				)
    |shift -> ip3		( arg2				)
    |shift -> port		( arg3				)

( crib: :port nil |ged -> port )


    ( Kill the timeout task: )
    [ @.task taskId | task:killTask ]pop

    ( Invoke user-supplied iofn: ) 
    fn if
	port       |unshift 
	ip3        |unshift 
	ip2        |unshift 
	ip1        |unshift 
	ip0        |unshift 
	from       |unshift 
	taskId     |unshift 
	fa if fa   |unshift fi
	fn call{ [] -> [] }
    fi
    ]pop

    [ |
( .sys.muqPort d, "(347)<" d, @ d, ">requestGetMuqnetUserIoFn/zzz\n" d, )
;
'requestGetMuqnetUserIoFn export

( =====================================================================	)
( - requestGetMuqnetUserTimeoutFn -- Support fn.				)

:   requestGetMuqnetUserTimeoutFn { [] -> [] }
( .sys.muqPort d, "(347)<" d, @ d, ">requestGetMuqnetUserTimeoutFn/aaa\n" d, )
    |shift -> taskId		( From task:runSomePendingTasks		)
    |shift -> tries		( targ0					)
    |shift -> delay		( targ1					)
    |shift -> am		( targ2					)
    |shift -> errfn		( targ3					)
    |shift -> fa		(  arg0					)
    |shift -> iofn		(  arg1					)
    |shift -> ip0		(  arg2					)
    |shift -> ip1		(  arg3					)
    |shift -> ip2		(  arg4					)
    |shift -> ip3		(  arg5					)
    |shift -> port		(  arg6					)
    ]pop

    @.task.taskState -> av

    tries 0 <= if
( .sys.muqPort d, "(347)<" d, @ d, ">requestGetMuqnetUserTimeoutFn retrying\n" d, )
	( Send timeout report to user shell: )
	av :userIo get? -> uio if	( Isle daemons don't have user shells	)
	    "GetMuqnetUser timed out, task id = " taskId toString join vals[
		"eko" t uio
		|maybeWriteStreamPacket
		pop pop
	    ]pop
	fi
    else
( .sys.muqPort d, "(347)<" d, @ d, ">requestGetMuqnetUserTimeoutFn giving up\n" d, )
        "GetMuqnetUser no response retrying:  task id " taskId toString join oldmud:echo

	( Retry: )
	( Submit continuation task: )
	[   @.task			( task:home instance	)
	    delay			( when			)
	    taskId			( taskId		)
	    nil				( who			)
	    nil				( why			)
	    4				( targs			)
	    'requestGetMuqnetUserTimeoutFn	( timeout fn		)
            'requestGetMuqnetUserIoFn
	    tries 1-			( targ0 		)
	    delay			( targ1 		)
	    am				( targ3 		)
	    errfn			( targ4 		)
	    fa				(  arg0 		)
	    iofn			(  arg1 		)
	    ip0				(  arg2 		)
	    ip1				(  arg3 		)
	    ip2				(  arg4			)
	    ip3				(  arg5 		)
	    port			(  arg6 		)
	| task:ioDo ]-> taskId
	[ @.task.taskState | oldmud:doNop ]pop

	( Send request: )
	[   @.task.taskState.io ip0 ip1 ip2 ip3 port taskId | muqnet:sendGetMuqnetUserInfo ]pop
    fi

    [ |
( .sys.muqPort d, "(347)<" d, @ d, ">requestGetMuqnetUserTimeoutFn/zzz\n" d, )
;
'requestGetMuqnetUserTimeoutFn export

( =====================================================================	)
( - ]requestGetMuqnetUser -- Ask for info on some Muq's muqnet user.	)

:   ]requestGetMuqnetUser { [] -> }
( .sys.muqPort d, "(347)<" d, @ d, ">]requestGetMuqnetUser/aaa\n" d, )
    ( Sanity checks: )

    :errFn  nil |gep -> errfn
    :fn      nil |gep -> iofn
    :fa      nil |gep -> fa
    :am      nil |gep -> am
    :port  30000 |gep -> port
    :ip0     128 |gep -> ip0
    :ip1      83 |gep -> ip1
    :ip2     194 |gep -> ip2
    :ip3      21 |gep -> ip3
    :delay   nil |gep -> delay
    :retries nil |gep -> retries
    :taskId nil |gep -> taskId
    |length 0 != if "task:]requestGetMuqnetUser unrecognized keyword argument" simpleError fi
    ]pop
 
    iofn symbol? not if
        iofn callable? not if
            "task:]requestGetMuqnetUser iofn arg must be a callable value" simpleError
    fi  fi

    delay   integer? not if @.task.taskDelay   -> delay   fi
    retries integer? not if @.task.taskRetries -> retries fi

    ( Submit continuation task: )
    [   @.task			( TASK:HOME instance	)
	delay				( when			)
	taskId				( taskId		)
	nil				( who			)
	nil				( why			)
        4				( targs			)
	'requestGetMuqnetUserTimeoutFn	( timeout fn		)
        'requestGetMuqnetUserIoFn		( io fn			)
	retries				( targ0 )
	delay				( targ1 )
	am				( targ2 )
	errfn				( targ3 )
	fa				(  arg0 )
	iofn				(  arg1 )
	ip0				(  arg2 )
        ip1				(  arg3 )
        ip2				(  arg4 )
        ip3				(  arg5 )
        port				(  arg6 )
    | task:ioDo ]-> taskId
    [ @.task.taskState | oldmud:doNop ]pop

    ( Send request: )
( .sys.muqPort d, "(347)<" d, @ d, ">requestGetMuqnetUser @.task = " d, @.task d, "\n" d, )
( .sys.muqPort d, "(347)<" d, @ d, ">requestGetMuqnetUser @.task.taskState = " d, @.task.taskState d, "\n" d, )
( .sys.muqPort d, "(347)<" d, @ d, ">requestGetMuqnetUser @.task.taskState.io = " d, @.task.taskState.io d, )
( "\n" d, )
    [   @.task.taskState.io ip0 ip1 ip2 ip3 port taskId | muqnet:sendGetMuqnetUserInfo ]pop
( .sys.muqPort d, "(347)<" d, @ d, ">]requestGetMuqnetUser/zzz\n" d, )
;
']requestGetMuqnetUser export

"oldmud"  inPackage
'task:]requestGetMuqnetUser import

"oldmsh"  inPackage
'task:]requestGetMuqnetUser import

"task" inPackage

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example




