@c -^C^O^A to show All of file.
@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)
@example  @c

( - 345-W-oldtask.muf -- Generic delayedExecution daemon support.	)
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
( As support for distributed processing, an 'ioDo' function is also	)
( supported.  The intention here is to support an asynchronous		)
( request to another daemon, where we want to execute a given IOFN	)
( function when the reply is recieved, and to timeout after some	)
( number of milliseconds, optionally executing an alternate FN function	)
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
( Note that asynch does NOT delete the task from the task queue when	)
( invoking an IOFN.  This is to reduce the danger of other users	)
( accidentally or maliciously deleting tasks by shipping us bogus	)
( IT values.  The IOFN should check that the given packet is as		)
( expected, then delete the task itself using ASYNCH:KILL-TASK. In some	)
( cases, where multiple incoming requests are to be handled by the	)
( same task, the task may in fact be left in the task queue.		)




( =====================================================================	)
( - Package 'task' --							)

"TASK" rootValidateDbfile pop
[ "task" .db["TASK"] | ]inPackage

me$s.lib["task"] --> .lib["task"]



( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - home -- State record for daemons supporting delayed execution.	)

( 'task:home' contains the information we need to support		)
( delayed execution.							)
(									)
( TASK-JOB is daemon job currently animating us.			)
(									)
( TASK-STATE is state record of daemon job currently animating us.	)
(									)
( TASK-NEXT-ID is next task id to issue, an integer.			)
(									)
( TASK-ID is a stack of request IDs, useful for deleting a task.	)
(									)
( TASK-WHEN is a stack of execution times.				)
(									)
( TASK-FN is a stack of matching functions to invoke.			)
(									)
( TASK-IOFN is like TASK-FN, but the functions are invoked on receipt	)
(	of an I/O packet with our ID instead of at timeout.		)
(									)
( TASK-ARGNO is a stack of matching argument counts.			)
(									)
( TASK-TARGS is a stack of matching argument counts specifying how	)
(          many of the arguments should be given only to the timeout	)
(	   function, not to the iofn.					) 
(									)
( TASK-ARG0 through TASK-ARGC are stacks holding matching arguments.	)
(									)
( TASK-RETRIES is default number of times to retry an asynchronous	)
(	  request before timing out.					)
(									)
( taskDelay is default time in milliseconds to wait between retries	)
(         of an asynchronous request.					)

"345-W-oldtask: SETTING TASKDELAY TIMEOUT VALUE UNREALISTICALLY LARGE\n" d,
defclass: home
    :export  t

    :slot :taskJob	:prot "rw----"	 :initval  nil
    :slot :taskState	:prot "rw----"	 :initval  nil
    :slot :taskNextId	:prot "rw----"	 :initform :: trulyRandomFixnum -> t  t 0 > if t neg -> t fi  t ;
    :slot :taskRetries	:prot "rw----"	 :initval  20 ( oggub, 4 is a better debug value. )
    :slot :taskDelay	:prot "rw----"	 :initval  1000 ( buggo, should use shorter production value )
    :slot :taskId	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskWhen	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskFn	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskIofn	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskWhy	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskWho	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArgno	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskTargs	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArg0	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArg1	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArg2	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArg3	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArg4	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArg5	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArg6	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArg7	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArg8	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArg9	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArga	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArgb	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskArgc	:prot "rw----"	 :initform :: makeStack ;
    :slot :taskLock	:prot "rw----"	 :initform :: makeLock  ;
;
 
( =====================================================================	)

( - Generic Functions -							)

( =====================================================================	)
( - killAllJobs -- Clear all pending jobs.				)

defgeneric: killAllJobs {[ $       ]} ;
defmethod:  killAllJobs { 't        } ;
defmethod:  killAllJobs { 'home  }
    {[              'us      ]}

    us.taskLock withLockDo{
	us.taskWhen  reset
	us.taskIt    reset
	us.taskFn    reset
	us.taskIofn  reset
	us.taskWhy   reset
	us.taskWho   reset
	us.taskArgno reset
	us.taskTargs reset
	us.taskArg0  reset
	us.taskArg1  reset
	us.taskArg2  reset
	us.taskArg3  reset
	us.taskArg4  reset
	us.taskArg5  reset
	us.taskArg6  reset
	us.taskArg7  reset
	us.taskArg8  reset
	us.taskArg9  reset
	us.taskArga  reset
	us.taskArgb  reset
	us.taskArgc  reset
    }

    [ |
;
'killAllJobs export

( =====================================================================	)
( - task -- Submit a function call for later execution.			)

( TASK args are:							)
(    US    task:home instance.						)
(    WHEN  integer time at which to execute FN.				)
(    ID    usually NIL, else integer to use as task id.			)
(    WHO   usually NIL, else Guest/User whom reply must be from.	)
(    WHY   NIL, else text name for task -- human info only.		)
(    TARGS Integer count of ARGS to be dropped -- see below.		)
(    FN    Function to invoke when time is up, else NIL.		)
(          FN is passed task id followed by ARGS.			)
(    IOFN  Function to invoke when daemon receives packet with IT==ID	)
(	   IOFN is passed task id folled by ARGS followed by packet.	)
(    ARGS  All remaining ARGS (up to 13) are passed to FN.		)
(	   All but the first TARGS of the ARGS are passed to IOFN.	)
(									)
( TASK returns a block containing the integer task ID.  Task ids	)
(	  are normally generated by incrementing a counter starting	)
(	  at zero, but may be explicitly provided via the ID argument.	)
(	  Explicitly providing the value may be useful when you are	)
(	  chaining a series of tasks together as a logical thread,	)
(	  and wish to be able to abort the thread at any time using	)
(	  a single fixed task ID.  Usually you will still allow TASK	)
(	  to specify that task ID in the first call, to reduce the	)
(	  danger of colliding with a task ID already in use.		)

defgeneric: task {[ $     $  $  $  $  $ ]} ;
defmethod:  task { 't    't 't 't 't 't  } ;
defmethod:  task { 'home 't 't 't 't 't  }
( .sys.muqPort d, "(345)<" d, @ d, ">task:task/aaa\n" d, )
    |shift -> us
( .sys.muqPort d, "(345)<" d, @ d, ">task:task us= " d, us d, "\n" d, )
    |shift -> when
( .sys.muqPort d, "(345)<" d, @ d, ">task:task when= " d, when d, "\n" d, )
    |shift -> id
( .sys.muqPort d, "(345)<" d, @ d, ">task:task id= " d, id d, "\n" d, )
    |shift -> who
( .sys.muqPort d, "(345)<" d, @ d, ">task:task who= " d, who d, "\n" d, )
    |shift -> why
( .sys.muqPort d, "(345)<" d, @ d, ">task:task why= " d, why d, "\n" d, )
    |shift -> targs	( First TARGS args passed to FN but not IOFN. )
( .sys.muqPort d, "(345)<" d, @ d, ">task:task targs= " d, targs d, "\n" d, )
    |shift -> fn
( .sys.muqPort d, "(345)<" d, @ d, ">task:task fn= " d, fn d, "\n" d, )
    |shift -> iofn
( .sys.muqPort d, "(345)<" d, @ d, ">task:task iofn= " d, iofn d, "\n" d, )

    ( Sanity checks: )

    id if id integer? not if "task:task ID must be an integer" simpleError fi fi
( .sys.muqPort d, "(345)<" d, @ d, ">task:task.bbb\n" d, )
    when integer?     not if "task:task DATE must be an integer" simpleError fi
( .sys.muqPort d, "(345)<" d, @ d, ">task:task.ccc\n" d, )

    fn callable? not if "task:task fn must be a callable value" simpleError fi
( .sys.muqPort d, "(345)<" d, @ d, ">task:task.ddd\n" d, )

    ( Be nice to check that fn signature is { [] -> [] } here.... )

    ( Count arguments: )
    |length -> argno
    argno 13 > if "task:task fn accepts at most 13 arguments currently" simpleError fi
( .sys.muqPort d, "(345)<" d, @ d, ">task:task/eee\n" d, )
    targs argno > if "task:task TARGS must be less than ARGNO" simpleError fi
( .sys.muqPort d, "(345)<" d, @ d, ">task:task/fff\n" d, )


    ( Save everything: )
    us.taskLock withLockDo{
	id not if
	    us.taskNextId -> id   id 1 + --> us.taskNextId
	fi
( .sys.muqPort d, "(345)<" d, @ d, ">task:task/ggg: when = " d, when getUniversalTime - d, " id=" d, id d, "\n" d, )
	id                                 us.taskId    push
	when                               us.taskWhen  push
	fn                                 us.taskFn    push
	iofn                               us.taskIofn  push
	argno                              us.taskArgno push
	why                                us.taskWhy   push
	who                                us.taskWho   push
	targs                              us.taskTargs push
	|length 0 > if |shift else nil fi  us.taskArg0  push
	|length 0 > if |shift else nil fi  us.taskArg1  push
	|length 0 > if |shift else nil fi  us.taskArg2  push
	|length 0 > if |shift else nil fi  us.taskArg3  push
	|length 0 > if |shift else nil fi  us.taskArg4  push
	|length 0 > if |shift else nil fi  us.taskArg5  push
	|length 0 > if |shift else nil fi  us.taskArg6  push
	|length 0 > if |shift else nil fi  us.taskArg7  push
	|length 0 > if |shift else nil fi  us.taskArg8  push
	|length 0 > if |shift else nil fi  us.taskArg9  push
	|length 0 > if |shift else nil fi  us.taskArga  push
	|length 0 > if |shift else nil fi  us.taskArgb  push
	|length 0 > if |shift else nil fi  us.taskArgc  push
    }
    ]pop

    [ id |
( .sys.muqPort d, "(345)<" d, @ d, ">task:task/zzz\n" d, )
;
'task export

( =====================================================================	)
( - do -- Submit a function call for later execution.			)

:   do { [] -> [] }

( .sys.muqPort d, "(345)<" d, @ d, ">task:do/aaa\n" d, )
    ( DO args are:							)
    (    US    task:home instance.					)
    (    WHEN  integer time at which to execute FN.			)
    (    ID    usually NIL, else integer to use as task id.		)
    (    WHY   NIL, else text name for task (human info only).		)
    (    FN    Function to invoke when time is up, else NIL.		)
    (          FN is passed task id followed by ARGS.			)
    (    ARGS  All remaining ARGS (up to 13) are passed to FN.		)
    (	   All but the first TARGS of the ARGS are passed to IOFN.	)

    ( Supply 0 TARGS: )
    0   4 |pushNth

    ( Supply NIL iofn: )
    nil 6 |pushNth

    ( Delegate rest of work: )
    'task:task call{ [] -> [] }
( .sys.muqPort d, "(345)<" d, @ d, ">task:do/zzz\n" d, )
;
'do export

( =====================================================================	)
( - inDo -- Same as task:do, but relative instead of absolute time.	)

:   inDo { [] -> [] } 

( .sys.muqPort d, "(345)<" d, @ d, ">task:inDo/aaa\n" d, )
    ( inDo args are:							)
    (    US    task:home instance.					)
    (    WHEN  milliseconds to wait before executing FN.		)
    (    ID    usually NIL, else integer to use as task id.		)
    (    WHY   NIL, else text name for task (human info only).		)
    (    FN    Function to invoke when time is up, else NIL.		)
    (          FN is passed task id followed by ARGS.			)
    (    ARGS  All remaining ARGS (up to 13) are passed to FN.		)
    (	   All but the first TARGS of the ARGS are passed to IOFN.	)

    ( Sanity checks: )
    |length 5 < if "task:inDo needs at least 5 args in block" simpleError fi

    ( Convert time from relative to absolute spec: )
    1 |dupNth -> when
    when getUniversalTime + -> when
    when 1 |setNth

    ( Supply nil WHO: )
    nil 3 |pushNth

    ( Supply 0 TARGS: )
    0   5 |pushNth

    ( Supply NIL iofn: )
    nil 7 |pushNth

    ( Delegate rest of work: )
    'task:task call{ [] -> [] }
( .sys.muqPort d, "(345)<" d, @ d, ">task:inDo/zzz\n" d, )
;
'inDo export



( =====================================================================	)
( - ioDo -- Same as task:inDo, but explicit IO-FN and TARGS		)

:   ioDo { [] -> [] } 

( .sys.muqPort d, "(345)<" d, @ d, ">task:ioDo/aaa\n" d, )
    ( Sanity checks: )
    |length 7 < if "ioDo needs at least 7 args in block" simpleError fi

    ( Convert time from relative to absolute spec: )
    1 |dupNth -> when
    when getUniversalTime + -> when
    when 1 |setNth

    ( Delegate rest of work: )
    'task:task call{ [] -> [] }
( .sys.muqPort d, "(345)<" d, @ d, ">task:ioDo/zzz\n" d, )
;
'ioDo export

( =====================================================================	)
( - killTask -- Kill task with given id.				)

defgeneric: killTask {[ $        $  ]} ;
defmethod:  killTask { 't       't   } ;
defmethod:  killTask { 'home 't      }
    {[                  'us      'id ]}

    ( Sanity check: )
    id integer? not if [ nil | return fi

    ( Find task with given id: )
    us.taskLock withLockDo{
	us.taskId    -> ids
	ids length -> len
	for w from 0 below len do{
	    ids[w] id = until
	}
	w len = if [ nil | return fi

	( Kill selected task: )
	us.taskWhen  w deleteBth
	us.taskFn    w deleteBth
	us.taskIofn  w deleteBth
	us.taskId    w deleteBth
	us.taskWhy   w deleteBth
	us.taskWho   w deleteBth
	us.taskArgno w deleteBth
	us.taskTargs w deleteBth
	us.taskArg0  w deleteBth
	us.taskArg1  w deleteBth
	us.taskArg2  w deleteBth
	us.taskArg3  w deleteBth
	us.taskArg4  w deleteBth
	us.taskArg5  w deleteBth
	us.taskArg6  w deleteBth
	us.taskArg7  w deleteBth
	us.taskArg8  w deleteBth
	us.taskArg9  w deleteBth
	us.taskArga  w deleteBth
	us.taskArgb  w deleteBth
	us.taskArgc  w deleteBth
    }

    [ t |
;
'killTask export

( =====================================================================	)
( - runSomePendingTasks -- Execute some past-due function calls.	)

defgeneric: runSomePendingTasks {[ $      $         ]} ;
defmethod:  runSomePendingTasks { 't     't          } ;
defmethod:  runSomePendingTasks { 'home  't          }
    {[                               'us    'maxCalls ]}
( .sys.muqPort d, "(345)<" d, @ d, ">task:runSomePendingTasks/aaa\n" d, )

    maxCalls integer? not if "maxCalls arg must be an integer" simpleError fi
    maxCalls 0 <=         if "maxCalls arg must be > 0" simpleError fi

    ( What time is it? )    
    getUniversalTime -> now

    ( Execute at most maxCalls pending functions: )
    for i from 0 below maxCalls do{

	( Find a candidate call: )
	us.taskLock withLockDo{
	    us.taskWhen  -> when
	    when length -> len
	    for w from 0 below len do{
		when[w] now <= until
	    }
	    w len = if
( .sys.muqPort d, "(345)<" d, @ d, ">task:runSomePendingTasks/zzz.A (no pending)\n" d, )
		[ | return
	    fi

	    ( Extract selected task: )
	    us.taskId[w]    -> id
	    us.taskFn[w]    -> fn
	    us.taskWhy[w]   -> why
	    us.taskWho[w]   -> who
	    us.taskArgno[w] -> argno
	    us.taskTargs[w] -> targs
	    us.taskArg0[w]  -> arg0
	    us.taskArg1[w]  -> arg1
	    us.taskArg2[w]  -> arg2
	    us.taskArg3[w]  -> arg3
	    us.taskArg4[w]  -> arg4
	    us.taskArg5[w]  -> arg5
	    us.taskArg6[w]  -> arg6
	    us.taskArg7[w]  -> arg7
	    us.taskArg8[w]  -> arg8
	    us.taskArg9[w]  -> arg9
	    us.taskArga[w]  -> arga
	    us.taskArgb[w]  -> argb
	    us.taskArgc[w]  -> argc
	    
	    us.taskWhen  w deleteBth
	    us.taskFn    w deleteBth
	    us.taskIofn  w deleteBth
	    us.taskId    w deleteBth
	    us.taskWhy   w deleteBth
	    us.taskWho   w deleteBth
	    us.taskArgno w deleteBth
	    us.taskTargs w deleteBth
	    us.taskArg0  w deleteBth
	    us.taskArg1  w deleteBth
	    us.taskArg2  w deleteBth
	    us.taskArg3  w deleteBth
	    us.taskArg4  w deleteBth
	    us.taskArg5  w deleteBth
	    us.taskArg6  w deleteBth
	    us.taskArg7  w deleteBth
	    us.taskArg8  w deleteBth
	    us.taskArg9  w deleteBth
	    us.taskArga  w deleteBth
	    us.taskArgb  w deleteBth
	    us.taskArgc  w deleteBth
	}

	( Make the call: )
	fn if
( .sys.muqPort d, "(345)<" d, @ d, ">task:runSomePendingTasks/bbb: calling fn\n" d, )
	    [ |
	    id                 |push
	    why if why         |push  fi
	    who if who         |push  fi
	    argno  0 > if arg0 |push  fi
	    argno  1 > if arg1 |push  fi
	    argno  2 > if arg2 |push  fi
	    argno  3 > if arg3 |push  fi
	    argno  4 > if arg4 |push  fi
	    argno  5 > if arg5 |push  fi
	    argno  6 > if arg6 |push  fi
	    argno  7 > if arg7 |push  fi
	    argno  8 > if arg8 |push  fi
	    argno  9 > if arg9 |push  fi
	    argno 10 > if arga |push  fi
	    argno 11 > if argb |push  fi
	    argno 12 > if argc |push  fi
	    fn call{ [] -> [] }
	    ]pop
( .sys.muqPort d, "(345)<" d, @ d, ">task:runSomePendingTasks/bbb: back from fn\n" d, )
	fi
    }

    [ |
( .sys.muqPort d, "(345)<" d, @ d, ">task:runSomePendingTasks/zzz\n" d, )
;
'runSomePendingTasks export

( =====================================================================	)
( - runIoTask -- Execute a function call in response to io.		)

( This function is normally only called from the 'ack' processing	)
( section of the 350-W-olddaemon ']daemon' function, which handles	)
( per-user animation of possessions.					)

defgeneric: runIoTask {[ $      $       ]} ;
defmethod:  runIoTask { 't     't        } ;
defmethod:  runIoTask { 'home  't        }
( .sys.muqPort d, "(345)<" d, @ d, ">task:runIoTask/aaa\n" d, )

    |shift -> us	( Daemon's state record.			)
    |shift -> from	( The User/Guest who replied -- authenticated.	)
    |shift -> taskId	( Fixnum name of continuation ('task') to run.	)

    ( Find our call: )
    us.taskLock withLockDo{
	us.taskId  -> id
	id length -> len
	for w from 0 below len do{
	    id[w] taskId = until
	}
	w len = if
( .sys.muqPort d, "(345)<" d, @ d, ">task:runIoTask/zzz.A\n" d, )
	    ]pop [ | return
	fi

	( Extract selected task: )
	us.taskIofn[w]  -> iofn
	us.taskWhy[w]   -> why
	us.taskWho[w]   -> who
	us.taskArgno[w] -> argno
	us.taskTargs[w] -> targs
	us.taskArg0[w]  -> arg0
	us.taskArg1[w]  -> arg1
	us.taskArg2[w]  -> arg2
	us.taskArg3[w]  -> arg3
	us.taskArg4[w]  -> arg4
	us.taskArg5[w]  -> arg5
	us.taskArg6[w]  -> arg6
	us.taskArg7[w]  -> arg7
	us.taskArg8[w]  -> arg8
	us.taskArg9[w]  -> arg9
	us.taskArga[w]  -> arga
	us.taskArgb[w]  -> argb
	us.taskArgc[w]  -> argc
    }
( .sys.muqPort d, "(345)<" d, @ d, ">task:runIoTask from = " d, from d, "\n" d, )
( .sys.muqPort d, "(345)<" d, @ d, ">task:runIoTask who  = " d, who  d, "\n" d, )

    ( If 'who' is non-NIL, then we are to ignore any packets )
    ( from anyone else.  As a convenience to the caller, we  )
    ( allow 'who' to be a proxy or object, in which case we  )
    ( use the owner of the object or proxied object:         )
    who if
        who remote? if
	    who proxyInfo pop pop pop pop pop -> who_guest
	    who_guest     from != if ]pop [ | return fi
	else
	    who folk? not if
	        who$s.owner -> who_owner
		who_owner from != if ]pop [ | return fi
	    else
		who       from != if ]pop [ | return fi
    fi	fi  fi

    ( Make the call: )
    iofn if

	argno 12 > if argc |unshift  fi
	argno 11 > if argb |unshift  fi
	argno 10 > if arga |unshift  fi
	argno  9 > if arg9 |unshift  fi
	argno  8 > if arg8 |unshift  fi
	argno  7 > if arg7 |unshift  fi
	argno  6 > if arg6 |unshift  fi
	argno  5 > if arg5 |unshift  fi
	argno  4 > if arg4 |unshift  fi
	argno  3 > if arg3 |unshift  fi
	argno  2 > if arg2 |unshift  fi
	argno  1 > if arg1 |unshift  fi
	argno  0 > if arg0 |unshift  fi

	( First TARGS args don't get used here: )
	for i from 0 below targs do{ |shiftp }

	from             |unshift
	taskId           |unshift

( .sys.muqPort d, "(345)<" d, @ d, ">runIoTask calling iofn...\n" d, )
	iofn call{ [] -> [] }
( .sys.muqPort d, "(345)<" d, @ d, ">runIoTask back from iofn...\n" d, )

	]pop
    else
	]pop
    fi

    [ |
( .sys.muqPort d, "(345)<" d, @ d, ">task:runIoTask/zzz.B\n" d, )
;
'runIoTask export

( =====================================================================	)
( - timeUntilNextTask -- A value for ||readAnyStreamPacket		)

defgeneric: timeUntilNextTask {[ $     ]} ;
defmethod:  timeUntilNextTask { 't      } ]pop [ nil | ;
defmethod:  timeUntilNextTask { 'home   }
    {[                          'us    ]}

    ( What time is it? )    
    getUniversalTime -> now

    ( Time of first task: )
    us.taskLock withLockDo{
        us.taskWhen  -> when
	when length -> len
	len 0 = if [ nil | return fi
	when[0] -> earliest
( us.taskId  -> id .sys.muqPort d, "(345)<" d, @ d, ">timeUntilNextTask: when[0] = " d, earliest now - d, " id=" d, id[0] d, "\n" d, )
	for w from 1 below len do{
( .sys.muqPort d, "(345)<" d, @ d, ">timeUntilNextTask: when[" d, w d, "] = " d, when[w] now - d, " id=" d, id[w] d, "\n" d, )
	    when[w] earliest < if when[w] -> earliest fi
	}
    }

    ( Never return a negative or zero time to wait: )
    earliest now <= if [ 1 | return fi

( .sys.muqPort d, "(345)<" d, @ d, ">timeUntilNextTask: returning " d, earliest now - d, "\n" d, )
    [ earliest now - |
;
'timeUntilNextTask export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

