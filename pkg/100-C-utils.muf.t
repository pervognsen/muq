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

( - 100-C-utils.muf -- Miscellaneous Core functionality.		)
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
(		For Firiss:  Aefrit, a friend.				)
(									)
(  -------------------------------------------------------------------  )

(  -------------------------------------------------------------------  )
( Author:       Jeff Prothero						)
( Created:      94Mar26							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1995, by Jeff Prothero.				)
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
(  -------------------------------------------------------------------	)

( =====================================================================	)
( - Epigram.								)

( So intent, so serious upon his Studies, yt he ate very		)
( sparingly, nay, ofttimes he has forget to eat at all, so yt		)
( going into his Chamber, I have found his Mess untouch'd of		)
( wch when I have reminded him, [he] would reply, Have I; &		)
( then making to ye Table, would eat a bit or two standing...		)
( At some seldom Times when he design'd to dine in ye Hall,		)
( would turn to ye left hand, & go out into ye street, where		)
( making a stop, when he found his Mistake, would hastily turn		)
( back, & then sometimes instead of going into ye Hall, would		)
( return to his Chamber again... When he has sometimes taken a		)
( Turn or two [in the garden], has made a sudden stand, turn'd		)
( himself about, run up ye Stairs, like another Alchimedes		)
( [sic], with an [Eureka], fall to write on his Desk standing,		)
( without giving himself the Leasure to draw a Chair to sit		)
( down on.								)
( 									)
(  -- Contemporary description of Newton during his 1684-7 bash		)
(    writing the Principia, quoted in Westfall's _Life Of Isaac		)
(    Newton p162.							)

( The conviction began to possess him that a massive fraud,		)
( which began in the fourth and fifth centuries, had perverted		)
( the legacy of the early church.  Central to the fraud were		)
( the Scriptures, which Newton began to believe had been		)
( corrupted to support trinitarianism.  It is impossible to		)
( say exactly when the conviction fastened upon him.  The		)
( original notes themselves testify to early doubts.  Far from		)
( silencing the doubts, he let them possess him.  "For there		)
( are three that bear record in heaven, the Father, the Word,		)
( and the Holy Ghost: and these three are one."  Such is the		)
( wording of I John 5:7, which he read in his Bible.  "It is		)
( not read thus in the Syrian Bible," Newton discovered.  "Not		)
( by Ignatius, Justin, Irenaeus, Tertull. Origen, Athanasus.		)
( Nazienzen Didym Chrysostom, Hilarius, Augustine, Beda and		)
( others.  Perhaps Jerome is the first who reads it thus."		)
( "And without controversy great is the mystery of godliness:		)
( God was manifest in the flesh..." Thus I Timothy 3:16, in		)
( the orthodox version.  The word _God_ is obviously critical		)
( to the usefulness of the verse to support trinitarianism.		)
( Newton found that early versions did not contain the word		)
( but read only "great is the mystery of godliness which was		)
( manifested in the flesh." "Furthermore in the fourth and		)
( fifth centuries," he noted, "this place was not cited			)
( against the Arians."							)
(  -- Op Cit, Newton at his favorite study, along with alchemy --	)
(     physics and math were minor avocations in his opinion.		)
  
( =====================================================================	)

( - Forward declarations						)

"GEST" rootValidateDbfile pop
[ "guest" .db["GEST"] | ]inPackage

"QNET" rootValidateDbfile pop
[ "muqnet" .db["QNET"] | ]inPackage

'rootStart  export
'rootStart.function compiledFunction? not if
 :: { -> ! } ; --> 'rootStart.function
fi

"QNETA" rootValidateDbfile pop
[ "muqnetVars" .db["QNETA"] | ]inPackage

'_count export

( =====================================================================	)

( - Package declaration							)


( =====================================================================	)

( - Globals								)

"MUFV" rootValidateDbfile pop
[ "mufVars" .db["MUFV"] | ]inPackage

( Port assignments for standard Muq daemons.  You probably		)
( should NOT change any of these, but I've made them variables		)
( rather than constants just in case someone finds a good		)
( reason to change one.  These values should all be added to		)
( .sys.muqPort before actually being used to open a socket, to	)
( allow easy reconfiguration of the entire space of Muq server		)
( daemons.								)
(									)
( This list of constants is currently the closest Muq equivalent	)
( to the Unix .etc.services index of "well-known service" port		)
( assignments:								)
( 0   --> _muqnetPortOffset		'_muqnetPortOffset	export	)
23    --> _telnetPortOffset		'_telnetPortOffset	export
2000  --> _nanomudPortOffset		'_nanomudPortOffset	export

( This is the usual symbol handed as NEW-FN to rootAcceptLoginsOn,	)	
( meaning that if it has no function value, interactive creations of	)
( new accounts from the net is disabled, otherwise such creations are	)
( handled by the functional value of this symbol:			)
'_rootNewAccountFn export

"muf" inPackage

( =====================================================================	)

( - Public fns								)

( =====================================================================	)
( - ]writeStreamByLines                                                 )

:   ]writeStreamByLines { [] $ -> }
    -> stream

	( Figure length of block: )
	|length -> len

        ( Look up maximum packet we can )
	( send through this stream:     )
	stream.maxPacket -> lim

	( Write block to stream by '\n'-terminated )
        ( lines, but without exceeding 'lim':      )
	0 -> cat
	0 -> rat
	do{
	    ( Find end of next chunk to send: )
	    do{
		rat |dupNth -> c
	        rat 1 + -> rat
	        c '\n' =        if loopFinish fi
                rat cat - lim = if loopFinish fi
                rat len =       if loopFinish fi
            }

            ( Send next chunk: )
	    cat rat |subblock[
		"txt" t stream |writeStreamPacket pop pop
	    ]pop

            ( Iterate: )
	    rat -> cat
	    cat len =   if loopFinish fi
	}
    ]pop
;

( =====================================================================	)
( - makeBidirectionalMessageStream                                      )

:   makeBidirectionalMessageStream { -> $ $ }

    makeMessageStream -> a
    makeMessageStream -> b

    a --> b.twin
    b --> a.twin

    a b   
;
'makeBidirectionalMessageStream export

( =====================================================================	)
( - ,, ls* -- Fns to list keyvals on objects.				)

: ,, toDelimitedString , ;

: ls  foreach       key val do{ key ,, "\t" , val ,, "\n" , } ;
: lsh foreachHidden key val do{ key ,, "\t" , val ,, "\n" , } ;
: lss foreachSystem key val do{ key ,, "\t" , val ,, "\n" , } ;
: lsa foreachAdmins key val do{ key ,, "\t" , val ,, "\n" , } ;

',,  export
'ls  export
'lsh export
'lss export
'lsa export

( =====================================================================	)
( - |dup[ -- Duplicate a block.						)
(									)
( Phased out in favor of in-server implementation			)
(									)
( : |dup[ { [] -> [] [] ! } 						)
(    depth 1- -> hi							)
(    |length  -> len							)
(    hi len - -> lo							)
(    [   for i from lo below hi do{ i dupBth }   |			)
( ;									)
( '|dup[ export								)

( =====================================================================	)
( - explodeArity -- Break arity value into its components.		)

:   explodeArity { $ -> $ $ $ $ $ }
    -> arity

    arity            15 logand  -> typ
    arity  -4 ash    63 logand  -> blksIn
    arity -10 ash    63 logand  -> blksOut
    arity -16 ash   127 logand  -> argsIn
    arity -23 ash   127 logand  -> argsOut

    blksIn argsIn blksOut argsOut typ
;
'explodeArity export

( =====================================================================	)
( - implodeArity -- Construct arity value from its components.		)

:   implodeArity { $ $ $ $ $ -> $ }
    -> typ
    -> argsRet
    -> blksRet
    -> argsGet
    -> blksGet

    blksGet  4 ash -> blksGet
    blksRet 10 ash -> blksRet
    argsGet 16 ash -> argsGet
    argsRet 23 ash -> argsRet

    typ
    blksGet logior
    blksRet logior
    argsGet logior
    argsRet logior -> arity

    arity
;
'implodeArity export

0  -->constant arityNormal	    'arityNormal export
1  -->constant arityExit	    'arityExit export
2  -->constant arityBranch	    'arityBranch export
3  -->constant arityOther	    'arityOther export
4  -->constant arityCalli	    'arityCalli export
5  -->constant arityQ		    'arityQ export
6  -->constant arityStartBlock    'arityStartBlock export
7  -->constant arityEndBlock	    'arityEndBlock export
8  -->constant arityEatBlock	    'arityEatBlock export
9  -->constant arityCalla	    'arityCalla export
10 -->constant arityCallMethod    'arityCallMethod export

( =====================================================================	)
( - |sum -- Sum a block of numbers.					)

:   |sum { [] -> [] $ }
    0 -> sum
    |for n do{ sum n + -> sum }
    sum
;
'|sum export

( =====================================================================	)
( - pidToJob -- Find job with given pid.				)

( Find a job with given pid: )
:   pidToJob { $ -> $ }
    -> pid

    ( Generate block of all non-killed )
    ( jobs owned by current user:      )
   me$s.psQueue jobQueueContents[

        ( Over all entries in block: )
	|for j do{

	    j.name pid = if ]pop j return fi
        }
    ]pop 

    [ "No job with pid %d." pid | ]print simpleError
;

'pidToJob export

( =====================================================================	)
( - maybePidToJob -- Convert integer to job, no-op on non-int args.	)

( Find a job with given pid: )
:   maybePidToJob { $ -> $ }
    -> pid

    pid integer? if   pid pidToJob -> pid   fi

    pid
;

'maybePidToJob export

( =====================================================================	)
( - pf ps pv pxf pxs pxv -- Fns to show fns and vars in package.	)

( Show all functions in the current package: )
:   printFunctions { -> }
    @.package foreachHidden key val do{
        val symbolFunction -> fn
        fn if key , " " , fi
    }
    "\n" ,
;

( Show all symbols in the current package: )
:   printSymbols { -> }
    @.package foreachHidden key do{
        key , " " ,
    }
    "\n" ,
;

( Show all variables in the current package: )
:   printVariables { -> }
    @.package foreachHidden key val do{
(        val symbolValue -> val )
(        val if key , "\t" , val , "\n" , fi )
	val bound? if
	    key , "\t" , val symbolValue , "\n" ,
	fi
    }
;

( Show all exported functions in the current package: )
:   printExportedFunctions { -> }
    @.package foreach key val do{
        val symbolFunction -> fn
        fn if key , " " , fi
    }
    "\n" ,
;

( Show all exported symbols in the current package: )
:   printExportedSymbols { -> }
    @.package foreach key do{
        key , " " ,
    }
    "\n" ,
;

( Show all exported variables in the current package: )
:   printExportedVariables { -> }
    @.package foreach key val do{
        val symbolValue -> val
        val if key , "\t" , val , "\n" , fi
    }
;

'printFunctions export
'printSymbols export
'printVariables export
'printExportedFunctions export
'printExportedSymbols export
'printExportedVariables export

#'printFunctions --> #'pf
#'printSymbols --> #'ps
#'printVariables --> #'pv
#'printExportedFunctions --> #'pxf
#'printExportedSymbols --> #'pxs
#'printExportedVariables --> #'pxv

'pf export
'ps export
'pv export
'pxf export
'pxs export
'pxv export

( =====================================================================	)
( - pr -- printRestarts                       				)

:   printRestarts

    ( Over all available restarts: )
    0 -> i
    do{
	( Fetch next restart: )
	i getNthRestart
	-> name
	-> fn
	-> tFn
	-> iFn
	-> rFn
	-> data
	-> id

	( Done if no restart found: )
	id not if return fi

	( Summarize restart: )
        name , "\t" , rFn , "\n" ,

	( Next restart to try: )
	i 1 + -> i
    }
;
#'printRestarts --> #'pr
'printRestarts export
'pr export

( =====================================================================	)
( - ph -- printHandlers                       				)

:   printHandlers

    ( Over all available handlers: )
    [ |
        |getAllActiveHandlers[
            -> k
            -> hi
            -> lo
            for i from lo below hi do{
                i     dupBth -> eventN
                i k + dupBth -> handlerN

                eventN , "\t" , handlerN , "\n" ,
            }
        ]pop
    ]pop
;
#'printHandlers --> #'ph
'printHandlers export
'ph export

( =====================================================================	)
( - pj -- Print Jobs for current user.					)

:   printJobs { -> }

    ( Generate block of all non-killed )
    ( jobs owned by current user:      )
   me$s.psQueue jobQueueContents[

	( Print header: )
	"\n" ,
	" jobPid  jobSet  session  # stacks   opsDone queues\n" ,
	" -------- -------- -------- - -------- -------- --------\n" ,

        ( Over all entries in block: )
	|for j do{

	    ( Collect info about job: )
	    j.pid                -> pid
	    j.jobSet            -> jobset
	    jobset.jobsetLeader -> leader
	    leader.pid           -> jobsetPid
	    jobset.session       -> ssn
	    ssn.sessionLeader   -> sessionLeader
	    sessionLeader.pid   -> sessionPid
	    j.state              -> state
	    j.priority           -> priority
	    j.opCount            -> ops

	    j.dataStack.vector     -> dvec
	    j.loopStack.vector     -> lvec
	    dvec length2 lvec length2 + -> stacks

	    ( Print summary line: )
	    j @ = if "*" else " " fi ,	( Mark current job )
	    [ "%-8d " pid | ]print ,
	    [ "%-8d " jobsetPid | ]print ,
	    [ "%-8d " sessionPid | ]print ,
	    [ "%-1d " priority | ]print ,
	    [ "%-8d " stacks | ]print ,
	    [ "%-8d" ops | ]print ,
	    j jobQueues[ -> sleep
		|for q do{
		    " " , q.kind ,
		}
	    ]pop
	    sleep if
		[ " sleep(%d)" sleep | ]print ,
	    fi
	    "\n" ,
        }
    ]pop 
;
'printJobs export
#'printJobs --> #'pj
'pj export

( =====================================================================	)
( - rootPj -- Print Jobs for all users.					)

:   rootPrintJobs { -> }

    ( Generate block of all non-killed )
    ( jobs owned by all users:         )
    .ps jobQueueContents[

	( Print header: )
	"\n" ,
	" owner    jobPid   jobSet   session  # stacksiz opsDone  queues\n" ,
	" -------- -------- -------- -------- - -------- -------- --------\n" ,

        ( Over all entries in block: )
	|for j do{

	    ( Collect info about job: )
	    j.owner$s.name       -> owner
	    j.pid                -> pid
	    j.jobSet            -> jobset
	    jobset.jobsetLeader -> leader
	    leader.pid           -> jobsetPid
	    jobset.session       -> ssn
	    ssn :sessionLeader systemGet? -> sessionLeader if
		sessionLeader.pid   -> sessionPid
	    else
		0		       -> sessionPid
	    fi
	    j.state              -> state
	    j.priority           -> priority
	    j.opCount            -> ops

	    j.dataStack.vector     -> dvec
	    j.loopStack.vector     -> lvec
	    dvec length2 lvec length2 + -> stacks


	    ( Print summary line: )
	    j @ = if "*" else " " fi ,	( Mark current job )
	    [ "%-8s " owner | ]print ,
	    [ "%-8d " pid | ]print ,
	    [ "%-8d " jobsetPid | ]print ,
	    [ "%-8d " sessionPid | ]print ,
	    [ "%-1d " priority | ]print ,
	    [ "%-8d " stacks | ]print ,
	    [ "%-8d" ops | ]print ,
	    j rootOmnipotentlyDo{ jobQueues[ } -> sleep
		|for q do{
		    " " , q.kind ,
		}
	    ]pop
	    sleep if
		[ " sleep(%d)" sleep | ]print ,
	    fi
	    "\n" ,
        }
    ]pop 
;
'rootPrintJobs export
#'rootPrintJobs --> #'rootPj
'rootPj export

( =====================================================================	)
( - time -- Print " 9:45PM" or such.					)

:   time { -> $ } .sys.millisecsSince1970 "%l:%M%p" printTime ;
'time export

( =====================================================================	)
( - date -- Print "Fri Dec 7, 1941" or such.				)

:   date { -> $ } .sys.millisecsSince1970 "%a %b %e, %Y" printTime ;
'date export

( =====================================================================	)
( - printf -- Emulation of C printf, mostly for C users.		)

:   printf { [] -> } ]print , ;
'printf export

( =====================================================================	)
( - sprintf -- Emulation of C sprintf, mostly for MUC users.		)

:   sprintf { [] -> $ } ]print ;
'sprintf export

( =====================================================================	)
( - sscanf -- Emulation of C sscanf, mostly for MUC users.		)

:   sscanf { $ $ -> [] } unprint[ ;
'sscanf export

( =====================================================================	)
( - gets -- Emulation of C gets(), mostly for MUC users.		)

:   gets { -> $ }

    [ @.standardInput '\n' '\\'
    | |scanTokenToChar
    |popp
    |readTokenChars   ( Get token chars as block.      )
    |pop -> nextchar
    ]join
;
'gets export

( =====================================================================	)
( - getUniversalTime -- Return .sys.millisecsSince1970.			)

:   getUniversalTime { -> $ } .sys.millisecsSince1970 ;
'getUniversalTime export

( =====================================================================	)
( - debugOff -- Set to not enter debugger on uncaught signals.		)

:   debugOff { -> }   nil --> @.breakEnable  ;
'debugOff export

( =====================================================================	)
( - debugOn -- Set to enter debugger on uncaught signals.		)

:   debugOn { -> }   t --> @.breakEnable  ;
'debugOn export

( =====================================================================	)
( - pauseJob -- Move given job to pause queue.				)

:   pauseJob { $ -> }
    -> job

    job.owner          -> owner
    owner$s.pauseQueue  -> q
    job q queueJob
;
'pauseJob export

( =====================================================================	)
( - runJob -- Move given job to run queue.				)

:   runJob { $ -> }
    -> j

    j.owner      -> o
    o$s.runQueue1  -> q ( Doesn't matter which runQueue we pick. )
    j q queueJob
;
'runJob export

( =====================================================================	)
( - killJob -- Send .e.kill signal to job.				)

:   killJob { $ -> }
    -> j

    [ :event .e.kill :job j | ]signal
;
'killJob export


( =====================================================================	)
( - abortJob -- Send .e.abort signal to job.				)

:   abortJob { $ -> }
    -> j

    [ :event .e.abort :job j | ]signal
;
'abortJob export


( =====================================================================	)
( - forkJob -- Copy job, then start child running.			)

:   forkJob   { $ -> $ } -> name
    name copyJob -> j
    j if j runJob fi
    j
;
'forkJob export

( =====================================================================	)
( - forkJobset -- Copy jobset, then start child running.		)

:   forkJobset   { $ -> $ } -> name
    name copyJobset -> j
    j if j runJob fi
    j
;
'forkJobset export

( =====================================================================	)
( - forkSession -- Copy session, then start child running.		)

:   forkSession   { $ -> $ } -> name
    name copySession -> j
    j if j runJob fi
    j
;
'forkSession export

( =====================================================================	)
( - queryForFloat -- Convenience fn to read float interactively.	)

:   queryForFloat { $ $ $ $ -> $ }
    -> max
    -> was
    -> min
    -> what

    was min >= if
        [ "The '%s' was %g.\n" what was | ]print @.queryIo writeStream
    fi
    do{
        [ "Please enter new float value for '%s':\n" what
	| ]print @.queryIo writeStream

        @.queryIo readStreamLine pop trimString -> string
	string "%f" unprint[ |pop -> result ]pop

	result min < if
	    [ "Sorry, the '%s' must be at least %g\.n" what min
	    | ]print @.queryIo writeStream
	    loopNext
	fi

	result max > if
	    [ "Sorry, the '%s' must be at most %g.\n" what max
	    | ]print @.queryIo writeStream
	    loopNext	
	fi

	result return
    }
;
'queryForFloat export

( =====================================================================	)
( - queryForInt -- Convenience fn to read integer interactively.	)

:   queryForInt { $ $ $ $ -> $ }
    -> max
    -> was
    -> min
    -> what

    was min >= if
        [ "The '%s' was %d\n" what was | ]print @.queryIo writeStream
    fi
    do{
        [ "Please enter new integer value for '%s':\n" what
	| ]print @.queryIo writeStream

        @.queryIo readStreamLine pop trimString -> string
	string stringInt -> result

	result min < if
	    [ "Sorry, the '%s' must be at least %d\n" what min
	    | ]print @.queryIo writeStream
	    loopNext	
	fi

	result max >= if
	    [ "Sorry, the '%s' must be less than %d\n" what max
	    | ]print @.queryIo writeStream
	    loopNext	
	fi

	result return
    }
;
'queryForInt export

( =====================================================================	)
( - queryForString -- Convenience fn to read string interactively.	)

:   queryForString { $ $ -> $ }
    -> was
    -> what 

    was length 0 > if
        [ "The '%s' was '%s'.\n" what was
	| ]print @.queryIo writeStream
    fi
    do{
        [ "Please enter new string value for '%s':\n" what
	| ]print @.queryIo writeStream

        @.queryIo readStreamLine pop trimString -> result
	result length 0 > if result return fi

        [ "Sorry, the '%s' value must not be blank.\n" what
	| ]print @.queryIo writeStream
    }
;
'queryForString export

( =====================================================================	)
( - ]queryForChoice -- Convenience fn to select one of N strings.	)

:   ]queryForChoice { [] $ -> $ $ }
    -> prompt    prompt isAString

    |length -> len
    do{
	prompt length 0 = if
	  "\nPick one:\n" @.queryIo writeStream
	    "---------\n" @.queryIo writeStream
	else
	    [ "\n%s:\n" prompt | ]print @.queryIo writeStream
	fi

	0 -> i
	|for choice do{
	    i 1 + -> i	    

	    [ "%d) %s\n" i choice
	    | ]print @.queryIo writeStream
	}

        @.queryIo readStreamLine pop trimString -> string
	string stringInt 1 - -> result

	result 0 < if
	    "Sorry, choice must be at least 1\n"
	    @.queryIo writeStream
	    loopNext
	fi

	result len >= if
	    [ "Sorry, choice must be at most %d\n" len
	    | ]print  @.queryIo writeStream
	    loopNext
	fi

	result |dupNth -> resultString
	]pop
	result resultString return
    }
;
']queryForChoice export

( =====================================================================	)
( - oldMufShell -- Interactive MUF evaluation shell			)

( Phased out in favor of 12-C-muf.t/muf:]shell )

'exitShell export	( Forward declaration of symbol we'll need shortly. )

:   oldMufShell { [] -> @ }

    ( Pop argument block passed to us by  )
    ( ]exec -- it is usually empty here   )
    ( and anyhow we don't use it:         )
    ]pop

    ( Create a muf compiler: )
    makeFunction makeMuf -> muf

    ( Advertise it so users can talk to it if they wish: )
    muf --> @.compiler

    (      -- BEGIN BOILERPLATE --        )
    ( Note:  The following sequence is    )
    ( intended to allow standardized      )
    ( killing and unjamming of Muq jobs:  )
    ( I suggest all Muq shells just copy  )
    ( it verbatim in the absence of a     )
    ( strong reason to do otherwise.      )

    ( Establish a restart letting users   )
    ( to kill the job from the debugger:  )
    [   :function :: { -> ! } nil endJob ;
        :name 'endJob
        :reportFunction "Terminate job."
    | ]withRestartDo{               ( 1 )

    ( Establish a handler letting users   )
    ( terminate a job with a signal       )
    ( -- via 'killJob' say:              )
    [ .e.kill :: { [] -> [] ! } :why |get endJob ;
    | ]withHandlerDo{               ( 2 )

    ( Establish a restart letting users   )
    ( return to the main shell prompt     )
    ( from the debugger:                  )
    [   :function :: { -> ! }  'muf:abrt goto ;
	:name 'abort
	:reportFunction "Return to main mufShell prompt."
    | ]withRestartDo{               ( 3 )

    ( Establish a restart letting users   )
    ( exit this shell from the debugger:  )
    [   :function :: { -> ! }  'muf:exitShell goto ;
	:name 'exit
	:reportFunction "Exit from current shell."
    | ]withRestartDo{               ( 4 )

    ( Establish a handler letting users   )
    ( abort a job with a signal           )
    ( -- via 'abortJob' say:             )
    [ .e.abort :: { [] -> [] ! } 'abort invokeRestart ;
    | ]withHandlerDo{               ( 5 )

    ( Establish a handler that will kill  )
    ( us if we lose the net link:         )
    [ .e.brokenPipeWarning :: { [] -> [] ! } nil endJob ;
    | ]withHandlerDo{               ( 6 )

    withTags muf:abrt muf:exitShell do{    ( 7 ) ( Trap compile errs etc    )
    abrt                          ( Continuation from errors )
    (       -- END BOILERPLATE --         )



    ( Establish a handler that will print )
    ( active jobs on .etc.printJobs:     )
    [ .e.printJobs :: { [] -> [] ! } printJobs ;
    | ]withHandlerDo{               ( 8 )
    
    ( Configure socket to generate an     )
    ( .e.printJobs signal on ^T:       )
    @.jobSet.session.socket -> sock
    sock 20 .e.printJobs setSocketCharEvent



    ( Configure socket to generate an     )
    ( .e.abort signal on ^G:            )
    sock 7 .e.abort setSocketCharEvent



    ( Establish a handler that will dump  )
    ( us into debugger on .etc.debug:     )
    [ .e.debug :: { [] -> [] ! } "" break ;
    | ]withHandlerDo{               ( 9 )

    ( Configure socket to generate an    )
    ( .e.debug signal on ^Y:           )
    sock 25 .e.debug setSocketCharEvent



    ( Start up telnet daemon if we're on a )
    ( netlink and none is running:         )
    telnet:maybeStartTelnetDaemon


    [ "\n\n ** Welcome to Muq %s **\n\n" .muq.version | ]print ,
    @.package$s.name , ":\n" ,  ( Issue initial prompt     )
    readLine                     ( Read a line              )
    0 muf setMufLineNumber     ( Count from fn start      )
    muf startMufCompile         ( Set up to compile it     )
    do{                           ( Infinite loop over input )
	do{
	    muf continueMufCompile ( Compile it            )
	until }
	if                        ( fn completed             )
	    call                  ( Call fn.                 )
	    @.package$s.name , ": " , ( prompt             )
	    print1DataStack ,   ( Print out data stack     )
	    "\n" ,                ( New line for user input  )
	    readLine             ( Read a line              )
	    0 muf setMufLineNumber ( Count from fn start  )
	    muf startMufCompile ( Set up to compile it     )
	else                      ( fn not completed yet     )
	    ,                     ( Issue next prompt        )
	    readLine             ( Another src line         )
	    muf addMufSource    ( Append to source string  )
	fi                        ( fn completed             )
    }                             ( Infinite loop over input )


    exitShell                    ( Exit from shell          )
    } ( 9 )
    } ( 8 )
    } ( 7 )
    } ( 6 )
    } ( 5 )
    } ( 4 )
    } ( 3 )
    } ( 2 )
    } ( 1 )
;
'oldMufShell export

'mufShell export
( The following will normally be overwritten )
( by 140-C-muf-shell.muf.t:#']shell, but     )
( doing it here provides a fallback.  We     )
( avoid overwriting the 140-C-muf-shell      )
( shell if 100-C-utils gets reloaded later:  )
'mufShell.function not if
    #'oldMufShell --> #'mufShell
fi

( =====================================================================	)
( - changePassphrase -- Interactive fn to change passphrase		)

:   changePassphrase { -> }
    
    telnet:maybeWillEcho	( Try to suppress echoing during pw entry. )

    asMeDo{
	me$a.encryptedPassphrase "*" !=
    }
    if
	"Enter old passphrase:\n" ,
	[ @.standardInput '\n' nil |
	    |scanTokenToChar |popp
	    |readTokenChars   |popp
	    ( Add a salt to slow down dictionary attacks: )
	    me$s.nickName stringDowncase vals[ ||swap ]|join
	    |secureHash |secureHash
	]join -> encryptedPassphrase

	asMeDo{
	    me$a.encryptedPassphrase encryptedPassphrase !=
	}
	if
	    "Sorry!\n" ,
	    telnet:maybeWontEcho	( Restore normal echoing.	)
	    return
	fi
    fi

    "Enter new passphrase:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
	( Add a salt to slow down dictionary attacks: )
	me$s.nickName stringDowncase vals[ ||swap ]|join
	|secureHash |secureHash
    ]join -> encryptedPassphrase1

    "Re-enter new passphrase:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
	( Add a salt to slow down dictionary attacks: )
	me$s.nickName stringDowncase vals[ ||swap ]|join
	|secureHash |secureHash
    ]join -> encryptedPassphrase2

    telnet:maybeWontEcho	( Restore normal echoing.	)

    encryptedPassphrase1 encryptedPassphrase2 != if
	"Sorry -- they don't match!\n" ,
	return
    fi

    asMeDo{
	encryptedPassphrase1 --> me$a.encryptedPassphrase
    }
    "Done!\n" ,
;
'changePassphrase export

( =====================================================================	)
( - rootChangePassphrase -- Interactive fn to change user passphrase	)

:   rootChangePassphrase { -> }
    
    ( Sanity check: )
    @.actingUser root? not if
        "Must be root to use 'rootChangePassphrase'." simpleError
    fi

    "Enter name of user:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
    ]join -> name
    name stringDowncase -> lname
    .u lname get? -> user not if
        "I can't find a user by that name\n" ,
	return
    fi

    telnet:maybeWillEcho	( Try to suppress echoing during pw entry. )
    "Enter new passphrase for user:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
	( Add a salt to slow down dictionary attacks: )
	lname vals[ ||swap ]|join
	|secureHash |secureHash
    ]join -> encryptedPassphrase1

    "Re-enter new passphrase for user:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
	( Add a salt to slow down dictionary attacks: )
	lname vals[ ||swap ]|join
	|secureHash |secureHash
    ]join -> encryptedPassphrase2
    telnet:maybeWontEcho	( Restore normal echoing.	)

    encryptedPassphrase1 encryptedPassphrase2 != if
	"Sorry, they don't match!\n" ,
	return
    fi

    encryptedPassphrase1 --> user$a.encryptedPassphrase

    "Done!\n" ,
;
'rootChangePassphrase export

( =====================================================================	)
( - showLoginHints -- Display various reminders at login		)

:   showLoginHints { -> }
    nil -> shownHint
    me$s.loginHints index? not if return fi
    me$s.loginHints foreachHidden key val do{
	shownHint not if
	    "Hints from me$s.loginHints$h[1,2...]:\n" ,
	    t -> shownHint
	fi
        "  " , val ,
    }
;
'showLoginHints export

( =====================================================================	)
( - addLoginHint -- Note additional login reminders			)

:   addLoginHint { $ -> }
    -> hint

    ( "Integer?" is a special hack for root, )
    ( which gets created before NIL exists:  )
    me$s.loginHints not      if makeIndex --> me$s.loginHints fi
    me$s.loginHints integer? if makeIndex --> me$s.loginHints fi
    me$s.loginHints -> loginHints
    loginHints index? not if
	"me$s.loginHints not index?!" simpleError
    fi
    1 -> hintNumber
    do{
        loginHints hintNumber hiddenGet? pop while
        ++ hintNumber
    }
    hint --> loginHints$h[hintNumber]
;
'addLoginHint export

( =====================================================================	)
( - logout ---								)

:   logout { -> @ }

    ( Write farewell output to stream: )
    "Au revoir!\n" stringChars[ 
    "txt" t @.standardOutput |writeStreamPacket
    pop pop ]pop

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
'logout export

( =====================================================================	)
( - Default root hints							)

"For configuration menu do:       config\n"   addLoginHint
"To exit server from console do:  <CTRL>-C or rootShutdown\n" addLoginHint


( =====================================================================	)
( - addConfigFn -- Note additional configuration option			)

:   addConfigFn { $ $ -> }
    -> fn
    -> label

    ( "Integer?" is a special hack for root, )
    ( which gets created before NIL exists:  )
    me$s.configFns not      if makeIndex --> me$s.configFns fi
    me$s.configFns integer? if makeIndex --> me$s.configFns fi
    me$s.configFns -> configFns
    configFns index? not if
	"me$s.configFns not index?!" simpleError
    fi
    fn --> configFns$h[label]
;
'addConfigFn export

( =====================================================================	)
( - configMenu -- Interactive re/configuration framework		)

:   configMenu { $ -> }
    -> labels

    "\n+--------< Config Options >--------\n" ,
    labels foreach key val do{
	"| " , key , ": " , val , "\n" ,
    }
    "| q: Quit config\n" ,
    "+----------------------------------\n" ,
;

( =====================================================================	)
( - config -- Interactive re/configuration framework			)

:   config { -> }

    me$s.configFns -> configFns
    configFns index? not if
	"No configuration options available.\n" ,
	return
    fi
    configFns hiddenKeys[ ]evec -> labels
    labels configMenu
    do{
	readLine trimString stringDowncase -> choice
	choice "q" = if return fi
	choice length 0 = if loopNext fi
	choice[0] digitChar? if
	    choice stringInt -> i
	    i 0 >= if
		i labels length < if
		    configFns$h[labels[i]] call{ -> }
		    labels configMenu
		    loopNext
	        fi
	    fi
	fi
	"?\n" ,
    }
;
'config export

( =====================================================================	)
( - ]logPrint -- User function to maybe print to logfile.		)

:   ]logPrint { [] -> }
    .muq.allowUserLogging not if ]pop return fi
    asMeDo{ ]rootLogPrint }
;
']logPrint export

( =====================================================================	)
( - log, -- User function to maybe write to logfile.			)

:   log, { $ -> }   -> str
    .muq.allowUserLogging not if return fi
    asMeDo{ str rootLogString }
;
'log, export

( ===================================================================== )
( - llss -- log lss to logfile						)

:   llss foreachSystem key val do{ [ "%s\t%s\n" key val | ]logPrint } ;
'llss export

( ===================================================================== )
( - reportAndLogEvent -- Alternative to reportEvent			)

:   reportAndLogEvent { [] -> } |shift -> ostream
    :formatString |get -> formatString
    formatString if
        [ "Sorry: %s\n" formatString | ]print ostream writeStream
        [ "Sorry: %s\n" formatString | ]logPrint
    else
        :event |get -> event
        [ "Sorry: %s\n" event$s.name | ]print ostream writeStream
        [ "Sorry: %s\n" event$s.name | ]logPrint
    fi
    ]pop
;
'reportAndLogEvent export

( ===================================================================== )
( - logEvent -- Alternative to reportEvent				)

:   logEvent { [] -> } |shift -> ostream
    :formatString |get -> formatString
    formatString if
        [ "Sorry: %s\n" formatString | ]logPrint
    else
        :event |get -> event
        [ "Sorry: %s\n" event$s.name | ]logPrint
    fi
    ]pop
;
'logEvent export

( =====================================================================	)
( - rootMakeAUser -- Convenience function to create a new User.		)

:   rootMakeAUser { $ -> }
    -> name

    ( Sanity checks: )
    @.actingUser root? not if
        "Must be root to use 'rootAMakeUser'." simpleError
    fi
    name string? not if
        "'rootAMakeUser' arg (user name) must be a string." simpleError
    fi

    ( Make name unique: )
    name -> n
    1    -> i
    do{
        ( Loop while name conflicts with established )
        ( nicknames or usernames:                    )
        n stringDowncase -> lname
        .folkBy.nickName n get? pop
        .u lname get? pop
        or while

	++ i
	[ name i toString | ]join -> n
    }

    n -> name
    name stringDowncase -> lname

(    .u lname get? pop if )
(        "A user of that name already exists." simpleError )
(    fi )

    me :dbfilePerUser get? -> dbfilePerUser pop

    [ lname | rootMakeUser |pop -> user ]pop

    user$s.lib            -> lib
    user$s.defaultPackage -> pkg


    ( Ensure everything following gets   )
    ( created in appropriate package and )
    ( dbfile:                            )
    @.lib     -> oldLib    ( Save current lib )
    @.package -> oldPkg    ( Save current pkg )
    lib --> @.lib
    pkg --> @.package      ( Buggo, need 'inPackageDo{ ... }' )

    user rootAsUserDo{

        lname --> pkg$s.name
        pkg   --> lib[lname]

        ( This is now no longer needed, .lib is now   )
        ( searched after @.lib:                       )
        ( .lib foreach key val do{ val --> lib[key] } )

        dh:g dh:p generateDiffieHellmanKeyPair -> longName -> trueName
        longName hash -> hashName
    }

    rootOmnipotentlyDo{

        'muf:oldMufShell  --> user$s.shell
        'telnet:start     --> user$s.telnetDaemon

        name              --> user$s.name
        name              --> user$s.nickName
        name              --> user$s.originalNickName

	user              --> .u[lname]
        user              --> .folkBy.nickName[name]
        user              --> .folkBy.hashName[hashName]

        lib               --> user$s.lib
	longName          --> user$s.longName
	trueName          --> user$s.trueName
	hashName          --> user$s.hashName

        ( Everyone should have their home )
        ( server as user server 0:        )
        .folkBy.nickName["muqnet"]$s.hashName --> user$s.userServer0

	( Defaults for other user servers )
	( vary on a per-system basis:     )
	.muq.defaultUserServer1              --> user$s.userServer1
	.muq.defaultUserServer2              --> user$s.userServer2
	.muq.defaultUserServer3              --> user$s.userServer3
	.muq.defaultUserServer4              --> user$s.userServer4

	( Everyone should have ip[0-3],port )
        ( set correctly:                    )
	.sys.ip0     --> user$s.ip0
	.sys.ip1     --> user$s.ip1
	.sys.ip2     --> user$s.ip2
	.sys.ip3     --> user$s.ip3
	.sys.muqPort --> user$s.port
    }

    ( Restore our original lib.pkg: )
    oldLib --> @.lib
    oldPkg --> @.package
;
'rootMakeAUser export

( =====================================================================	)
( - rootValidateUserNames -- longName/trueName/nickName/hashName	)

:   rootValidateUserNames { -> } 
    .u foreach key val do{

	rootOmnipotentlyDo{
	    val$s.longName 0 = if
		dh:g dh:p generateDiffieHellmanKeyPair -> longName -> trueName
		longName hash -> hashName

		key      --> val$s.originalNickName
		key      --> val$s.nickName
		longName --> val$s.longName
		trueName --> val$s.trueName
		hashName --> val$s.hashName
	    fi

	}
    }
;
'rootValidateUserNames export
rootValidateUserNames
 
( =====================================================================	)
( - rootValidateFolkBy -- .folkBy.hashName and .folkBy.nickName		)

:   rootValidateFolkBy { -> }
    . :folkBy get? pop not if
	makeIndex --> .folkBy
	".folkBy" --> .folkBy$s.name
    fi

    .folkBy :hashName get? pop not if
	makeIndex --> .folkBy.hashName
	".folkBy.hashName" --> .folkBy.hashName$s.name
    fi
    rootOmnipotentlyDo{
	.u foreach key val do{
	    val$s.hashName -> hashName
	    val --> .folkBy.hashName[hashName]
	}
    }

    .folkBy :nickName get? pop not if
	makeIndex --> .folkBy.nickName
	".folkBy.nickName" --> .folkBy.nickName$s.name
    fi
    rootOmnipotentlyDo{
	.u foreach key val do{
	    val$s.nickName -> nickName
	    val --> .folkBy.nickName[nickName]
	}
    }
;
'rootValidateFolkBy export
rootValidateFolkBy

( =====================================================================	)
( - rootValidateUserAddresses -- ip[0-4],port				)

:   rootValidateUserAddresses { -> } 
    .u foreach key val do{
	.folkBy.nickName["muqnet"]$s.hashName -> mq
	rootOmnipotentlyDo{

	    val$s.userServer0 mq != if
		mq --> val$s.userServer0
	    fi

	    ( Everyone should have ip[0-3],port )
	    ( set correctly:                    )
	    .sys.ip0     val$s.ip0  != if    .sys.ip0     --> val$s.ip0   fi
	    .sys.ip1     val$s.ip1  != if    .sys.ip1     --> val$s.ip1   fi
	    .sys.ip2     val$s.ip2  != if    .sys.ip2     --> val$s.ip2   fi
	    .sys.ip3     val$s.ip3  != if    .sys.ip3     --> val$s.ip3   fi
	    .sys.muqPort val$s.port != if    .sys.muqPort --> val$s.port  fi
	}
    }
;
'rootValidateUserAddresses export
 
( =====================================================================	)
( - rootIssueNewLongnamesToAllNatives -- 				)

:   rootIssueNewLongnamesToAllNatives { -> }

    ( Remove all natives from .folkBy.hashName, since their		)
    ( hashnames are about to change:					)
    .u foreach key val do{
	rootOmnipotentlyDo{
	    val$s.hashName -> hashName
	    delete: .folkBy.hashName[hashName]
	}
    }


    ( Assign new longnames to all natives, )
    ( and re-enter in .folkBy.hashName:   )
    .u foreach key val do{

	rootOmnipotentlyDo{
	    dh:g dh:p generateDiffieHellmanKeyPair -> longName -> trueName
	    longName hash -> hashName

	    longName --> val$s.longName
	    trueName --> val$s.trueName
	    hashName --> val$s.hashName

	    val --> .folkBy.hashName[hashName]
	}
    }

    ( Clear out invalidated shared secrets: )
    .u foreach key val do{
	rootOmnipotentlyDo{
	    val$s.sharedSecrets foreach k v do{
		delete: val$s.sharedSecrets[k]
	    }
	}
    }
;
'rootIssueNewLongnamesToAllNatives export



( =====================================================================	)
( - rootUpdateIPAddressesOfAllNatives -- 				)

:   rootUpdateIPAddressesOfAllNatives { -> }

    .sys        -> s

    s.ip0     -> ip0
    s.ip1     -> ip1
    s.ip2     -> ip2
    s.ip3     -> ip3
    s.muqPort -> port

    .u foreach key val do{
	rootOmnipotentlyDo{
	    ip0  --> val$s.ip0
	    ip1  --> val$s.ip1
	    ip2  --> val$s.ip2
	    ip3  --> val$s.ip3
	    port --> val$s.port
	}
    }
;
'rootUpdateIPAddressesOfAllNatives export


( =====================================================================	)
( - rootNoteGuest -- Add to .folkBy.hashName & .userBy.nickName		)

:   rootNoteGuest { $ $ $ -> $ }
    -> hashName
    -> longName
    -> nickName

    ( Check hashname: )
    longName hash hashName != if
        "rootMakeAGuest: hashName doesn't match longName?!" simpleError
    fi
 
    ( Ignore if we already have a record for this user: )
    .folkBy.hashName hashName get? -> u if   u return   fi
 
    ( Create record: )
    "GEST" rootMakeGuestInDbfile -> u
 
    rootOmnipotentlyDo{
	nickName --> u$s.originalNickName
    }

    ( Make nickName unique: )
    nickName -> n
    1        -> i
    do{
	.folkBy.nickName n get? pop while
	++ i
	[ nickName i toString | ]join -> n
    }
    n -> nickName

    ( Buggo, should probably duplicate the various  )
    ( names in the GEST dbfile before storing them: )

    ( Fill in values: )
    rootOmnipotentlyDo{
	nickName --> u$s.name
	nickName --> u$s.nickName
	longName --> u$s.longName
	hashName --> u$s.hashName
    }

    ( Enter record into our indices: )
    u --> .folkBy.nickName[nickName]
    u --> .folkBy.hashName[hashName]

    u
;
'rootNoteGuest export
 
( =====================================================================	)
( - rootAddUser -- Interactive function to create a new User.		)
:   rootAddUser { -> }

    @.actingUser root? not if
        "You must be root to add a user" ,
        return
    fi

    "Enter name for new user:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
    ]join -> name
    name stringDowncase -> lname
    .u lname get? pop if
        "You already have a user by that name\n" ,
	return
    fi

    telnet:maybeWillEcho	( Try to suppress echoing during pw entry. )
    "Enter passphrase for new user:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
	( Add a salt to slow down dictionary attacks: )
	lname vals[ ||swap ]|join
	|secureHash |secureHash
    ]join -> encryptedPassphrase1

    "Re-enter passphrase for new user:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
	( Add a salt to slow down dictionary attacks: )
	lname vals[ ||swap ]|join
	|secureHash |secureHash
    ]join -> encryptedPassphrase2
    telnet:maybeWontEcho	( Restore normal echoing.	)

    encryptedPassphrase1 encryptedPassphrase2 != if
	"Sorry, they don't match!\n" ,
	return
    fi

    name rootMakeAUser

    .u[lname] -> user
    encryptedPassphrase1 --> user$a.encryptedPassphrase

    "Done!\n" ,
;
'rootAddUser export

( =====================================================================	)
( - rootBecomeUser -- Switch job to being specified user.		)

( This function is intended to be used by login sorts of programs	)
( after validating user name and passphrase, to produce a job suitable	)
( for use by the user.  Thus, we want both @.actingUser and             )
( @.actualUser set to the specified user, plus we want the relevant     )
( stacks, message queues and so forth likewise owned by the specified   )
( user when we are done.                                                )

:   rootBecomeUser { $ -> @ }
    -> user

    ( Sanity checks: )
    @.actingUser root? not if
        "Must be root to use 'rootBecomeUser'." simpleError
    fi
    user user? not if
        "'rootBecomeUser' arg must be a user." simpleError
    fi

    ( In the usual case our job will have )
    ( two message streams hooked up to a  )
    ( socket, and we'd like them all to   )
    ( be owned by the user:               )
    @.jobSet.session.socket -> skt
    @.standardInput  -> src
    @.standardOutput -> dst
    src$s.twin          -> srcTwin
    dst$s.twin          -> dstTwin
( BUGGO, 'owner' field is no longer settable, since ownership )
( is now implicitly tied to which dbfile the object is in. We )
( We probably need a rootMoveToDbfile operation here which    )
( duplicates -- at minimum -- messageStream and socket        )
( objects within a given dbfile.  The alternative would be to )
( add 'owner' fields back to these objects and specialcase    )
( the relevant checks...?  Sounds icky.                       )



    ( Construct versions of the message streams and socket,    )
    ( owned by the user in question:                           )


    ( Currently, we always have:                        )
    (    @.standardInput       == @.standardOutput      )
    (    @.standardInput.twin  == @.standardOutput.twin )
    (    @.standardInput       != @.standardInput.twin  )
    (    socket.standardInput  == @.standardInput       )
    (    socket.standardOutput == @.standardInput.twin  )
    ( Might be nice to be more general at some point,   )
    ( but for now we'll assume the above holds:         )   

    ( Create & link the new stream and socket objects:  )
    rootOmnipotentlyDo{

	( What dbfile should the new objects go into? )
	user$s.dbname -> dbfile

	( Create the new objects: )
	skt     dbfile rootMoveToDbfile -> skt
	src     dbfile rootMoveToDbfile -> src
	srcTwin dbfile rootMoveToDbfile -> srcTwin

	( Join the twin message streams: )
	src     --> srcTwin.twin
	srcTwin --> src.twin

	( Update job stdin/out: )
	src     --> @.standardInput
	src     --> @.standardOutput

	( Ditto remaining standard streams: )
	src     --> @.terminalIo
	src     --> @.traceOutput
	src     --> @.queryIo
	src     --> @.debugIo

	( Update socket stdin/out: )
	src     --> skt.standardInput
	srcTwin --> skt.standardOutput

        ( Update session/socket links: )
	skt              --> @.jobSet.session.socket
	@.jobSet.session --> skt.session

	( Update redundenat local vars: )
        src     -> dst
        srcTwin -> dstTwin
    }

    ( The old code for changing ownership.  Now that ownership )
    ( is determined implicitly from the dbfile holding the     )
    ( object, the .owner field is necessarily read-only, and   )
    ( the following code no longer works:                      )
(   src      messageStream? if user -->     src$s.owner fi     )
(   dst      messageStream? if user -->     dst$s.owner fi     )
(   srcTwin  messageStream? if user --> srcTwin$s.owner fi     )
(   dstTwin  messageStream? if user --> dstTwin$s.owner fi     )
(   skt      socket?        if user -->     skt$s.owner fi     )
    ( For some reason, removing the above )
    ( '$s's hangs the regression suite?!  )
    
    ( Install correct package, lib &tc:   )
    user$s.lib             --> @$s.lib
    user$s.defaultPackage  --> @$s.package
    user$s.breakDisable    --> @$s.breakDisable
    user$s.breakEnable     --> @$s.breakEnable
    user$s.breakOnSignal   --> @$s.breakOnSignal
    user$s.doSignal callable? if
	user$s.doSignal    --> @$s.doSignal
    fi
    user$s.debugger callable? if
	user$s.debugger    --> @$s.debugger
    fi

    ( Set our new identity in job record. )
    ( Note that we set actingUser last   )
    ( because we lose all our superpowers )
    ( at that point:                      )
    user --> @$s.actualUser
    user --> @$s.actingUser

    ( Fork session and kill the parent,   )
    ( so we wind up with data and loop    )
    ( stacks owned by user.  This will    )
    ( also leave user owning any data     )
    ( structures implementing props on    )
    ( the job prop-er, plus jobset and    )
    ( session associated with job:        )
    "login" forkSession if
	nil endJob
    fi

    ( The new session has no socket, and  )
    ( the socket still points to the old  )
    ( session.  Fix that:                 )
    asMeDo{ 
	skt socket? if
	    @$s.jobSet$s.session -> ssn
	    skt --> ssn$s.socket
	    ssn --> skt$s.session       
	fi
    }

    ( 'cd' to the user object: )
    user cd

    ( Start the user's designated shell.  )
    ( It is essential to exec -something- )
    ( here, 'cause current shell usually  )
    ( has stuff owned by root which user  )
    ( can't modify:                       )
    user$s.shell -> shell
    shell callable? if
	[ | shell           ]exec
    else
        [ | 'oldMufShell ]exec
    fi
;
'rootBecomeUser export


( =====================================================================	)
( - ]rootExecUserDaemon -- Run daemon as specified user.		)

:   ]rootExecUserDaemon { [] -> @ }
    |shift -> user
    |shift -> daemon
    |shift -> io

    ( Sanity checks: )
    @$s.actingUser root? not if
        "Must be root to use 'rootExecUserDaemon'." simpleError
    fi
    user user? not if
        "'rootExecUserDaemon' user arg must be a user." simpleError
    fi
    daemon symbol? if
	daemon symbolFunction -> daemon
    fi
    daemon callable? not if
        "'rootExecUserDaemon' daemon arg must be callable value."
	simpleError
    fi
    io messageStream? not if
        "'rootExecUserDaemon' io arg must be a messageStream." simpleError
    fi
    io$s.owner user != if
        "'rootExecUserDaemon' io arg must be owned by user." simpleError
    fi

    io                    -> standardOutput
    standardOutput$s.twin -> standardInput

    ( Hook our streams up to ourself: )
    standardInput  --> @$s.standardInput
    standardInput  --> @$s.standardOutput
    standardInput  --> @$s.terminalIo
    standardInput  --> @$s.queryIo
    standardInput  --> @$s.debugIo
    standardInput  --> @$s.errorOutput
    standardInput  --> @$s.traceOutput

    
    ( Install correct package, lib &tc:   )
    user$s.lib             --> @$s.lib
    user$s.defaultPackage --> @$s.package
    user$s.breakDisable   --> @$s.breakDisable
    user$s.breakEnable    --> @$s.breakEnable
    user$s.breakOnSignal --> @$s.breakOnSignal
    user$s.doSignal callable? if
	user$s.doSignal   --> @$s.doSignal
    fi
    user$s.debugger callable? if
	user$s.debugger    --> @$s.debugger
    fi

    ( Set our new identity in job record. )
    ( Note that we set actingUser last   )
    ( because we lose all our superpowers )
    ( at that point:                      )
    user --> @$s.actualUser
    user --> @$s.actingUser

    ( Fork session and kill the parent,   )
    ( so we wind up with data and loop    )
    ( stacks owned by user.  This will    )
    ( also leave user owning any data     )
    ( structures implementing props on    )
    ( the job prop-er, plus jobset and    )
    ( session associated with job:        )
    "daemon" forkSession if nil endJob fi

    ( 'cd' to the user object: )
    user cd

    ( Start the daemon up with given argument block: )
    daemon ]exec
;
']rootExecUserDaemon export


( =====================================================================	)
( - ]execUserDaemon -- Run daemon for current user.			)

:   ]execUserDaemon { [] -> @ }
    |shift -> daemon
    |shift -> io

    ( Sanity checks: )
    daemon symbol? if
	daemon symbolFunction -> daemon
    fi
    daemon callable? not if
        "'execUserDaemon' daemon arg must be a callable value."
	simpleError
    fi
    io messageStream? not if
        "'execUserDaemon' io arg must be a messageStream." simpleError
    fi

    ( Fork session and kill the parent,   )
    ( so we wind up with data and loop    )
    ( stacks owned by user.  This will    )
    ( also leave user owning any data     )
    ( structures implementing props on    )
    ( the job prop-er, plus jobset and    )
    ( session associated with job:        )
    "userd" forkSession if nil endJob fi

    io                     -> standardOutput
    standardOutput$s.twin -> standardInput

    ( Hook our streams up to ourself: )
    standardInput  --> @$s.standardInput
    standardInput  --> @$s.standardOutput
    standardInput  --> @$s.terminalIo
    standardInput  --> @$s.queryIo
    standardInput  --> @$s.debugIo
    standardInput  --> @$s.errorOutput
    standardInput  --> @$s.traceOutput

    ( Start the daemon up with given argument block: )
    daemon ]exec
;
']execUserDaemon export


( =====================================================================	)
( - rootLoginUser -- Identify and validate a connecting user.		)

"mufVars" inPackage

"login:\n"      --> loginPrompt		'loginPrompt      export
"passphrase:\n" --> passphrasePrompt	'passphrasePrompt export

"muf" inPackage


:   rootLoginUser { [] -> @ ! } 
    |shift -> newFn
    ]pop

    ( ================================================== )
    ( The first version of this was just a function with )
    ( a do{...} loop.  Wyatt promptly pointed out that   )
    ( entering a null passphrase crashed it to the root  )
    ( prompt in the mufshell.  *BLUSH*!  Now we make it  )
    ( a very dumb shell in its own right, so if the user )
    ( finds a way to crash it, there's not much left.    )
    ( ================================================== )

    ( Disable debugger -- be bad news )
    ( if user could trigger an error  )
    ( leaving her/him at a debugger   )
    ( prompt without logging in!      )
    nil --> @$s.breakEnable

    ( Start up a telnet daemon so    )
    ( we can do passphrase blanking: )     
( buggo, this may be a security problem --   )
( should perhaps have a secure telnet daemon )
( supporting fewer commands for here.        )
    telnet:start

    ( Establish a restart letting users   )
    ( return to the main shell prompt     )
    ( from the debugger:                  )
    [   :function :: { -> ! }  'muf:abrt goto ;
	:name 'abort
	:reportFunction "Return to main loginShell prompt."
    | ]withRestartDo{               ( 1 )

    ( Establish a handler that will kill  )
    ( us if we lose the net link:         )
    [ .e.brokenPipeWarning :: { [] -> [] ! } nil endJob ;
    | ]withHandlerDo{               ( 2 )

    withTag muf:abrt do{       ( 3 ) ( Trap compile errs etc    )
    abrt                          ( Continuation from errors )
    (       -- END BOILERPLATE --         )

    do{
	newFn callable? if
	    "If you don't have an account, log in as 'NEW'\n" ,
	fi

	( Read purported name of user from net: )
	mufVars:loginPrompt ,
	readLine trimString -> name
	name "NEW" = if
	    newFn callable? if
		[ | newFn call{ [] -> [] } ]pop
	    else
		"Sorry, new account creation is currently switched off.\n" ,
	    fi
	else
	    name stringDowncase  -> lname
	    .u lname get? -> user pop

	    ( It is a good habit to prompt for pass- )
	    ( word even if user name is wrong:       )
	    telnet:willEcho	( Suppress echoing during pw entry. )
	    mufVars:passphrasePrompt ,
	    readLine trimString -> passphrase
	    telnet:wontEcho	( Restore normal echoing.	)
	    switchJob		( Give it time.  Be nice to	)
	    switchJob		( fix these race conditions...	)

	    ( The envelope please... )
	    user if
		( Do not allow banned players to log in: )
		user :bannedBy get? -> byWho if
		    [ "Log-in refused to: %s (banned by %s).\n" name byWho$s.nickName | ]logPrint
		    [ "Refused: %s was banned by %s\n" name byWho$s.nickName | ]print ,
		else
		    ( Do not let |secureHash crash )
		    ( us if passphrase is null: )
		    passphrase length 0 > if
			passphrase vals[
			    ( Add a salt to slow down dictionary attacks: )
			    lname vals[ ||swap ]|join
			    |secureHash |secureHash
			    user$a.encryptedPassphrase |=
                    if ]pop

			    [ "Logged in: %s.\n" name | ]logPrint

			    ( Shut down telnet daemon because  )
			    ( it is running as root, and we'll )
			    ( want one owned by the user:      )
			    telnet:stop
			    switchJob	( Give it time.  Another	)
			    switchJob  ( race condition to fix someday.	)

			    ( Convert to running as new user: )
			    user rootBecomeUser
			else
			    [ "Log-in refused to: %s.\n" name | ]logPrint

			    ]pop
			fi
		    fi
		fi
	    fi

	    "Sorry!\n" ,
	    5000 sleepJob	( To slow down passphrase-guessing attacks.	)
	fi
    }

    } ( 3 )
    } ( 2 )
    } ( 1 )
;

( =====================================================================	)
( - rootSpawnUser -- Start user shell on given skt.			)

:   rootSpawnUser { [] -> [] ! }
    |shift -> newSkt
    |shift -> newFn
    ]pop

    ( Spawn a new user shell and connect it to new skt: )
    "user" forkSession -> amParent	   ( Child gets NIL, parent gets child. )
    amParent not if

	( We're the child session: )

	( Create new input/output streamPair for ourself: )
        makeBidirectionalMessageStream
	-> standardInput	( jobToSocket )
	-> standardOutput	( socketToJob )

	( Hook new streams up to skt: )
	standardInput  --> newSkt$s.standardInput
	standardOutput --> newSkt$s.standardOutput

	( Find our session: )
	@$s.jobSet$s.session -> session

	( Introduce skt and session to each other: )
	session --> newSkt$s.session
	newSkt --> session$s.socket

	( Hook new streams up to ourself: )
	standardInput  --> @$s.standardInput
	standardInput  --> @$s.standardOutput
	standardInput  --> @$s.terminalIo
	standardInput  --> @$s.queryIo
	standardInput  --> @$s.debugIo
	standardInput  --> @$s.errorOutput
	standardInput  --> @$s.traceOutput

        [ newFn | 'rootLoginUser ]exec
	( Above will never return. )
    fi

    [ |
;

( =====================================================================	)
( - rootAcceptLoginsOn -- Start allowing user logins on given port	)

:   rootAcceptLoginsOn { [] -> [] }
    |shift -> port    port isAnInteger
    |shift -> newFn
    ]pop

    ( Fork off a separate process to listen for connects: )
    "getty" forkJob -> amParent	( Child gets NIL, parent gets child. )
    amParent not if

	( We're the child process: )

	( Make ourself a new input message stream: )
	makeMessageStream --> @$s.standardInput

	withTag abrt do{       ( 3 ) ( Trap compile errs etc    )

	    ( Tell server to start listening for connects: )
	    makeSocket    -> socket
	    @$s.standardInput --> socket$s.standardOutput
	    [   :socket socket
		:port   port
	    | ]listenOnSocket

	    nil if
	        abrt                          ( Continuation from errors )
	        "Port listener exiting\n" ,
	        nil endJob
	    fi
        }

	( Buggo, the following loop operates with the shell   )
        ( interpreter still on the callback stack -- it would )
        ( be a Very Bad Thing should a way be discovered of   )
	( inducing this function to drop back to the shell.   )
	( It would be safer to ]exec the following loop.      )

	withTag abrt do{       ( 3 ) ( Trap compile errs etc    )
	    abrt                     ( Continuation from errors )

	    ( Loop indefinitely, accepting connects )
	    ( and spawning user shells:             )
	    do{
		( Read one who+msg pair from )
		( the port listener:         )
		@$s.standardInput readStreamLine -> newSkt -> opcode

		( 'opcode' distinguishes the different messages  )
		( which the port listener might wish to send us. )
		(						     )
		( Currently the only such opcode defined is      )
		( "new", in which case 'newSkt' is a new skt    )
		( instance representing a new network	     )
		( connection:				     )
		opcode case{	

		on: "new"
		    [ newSkt newFn | rootSpawnUser ]pop

		else:
		    ( Should log a system error here, )
		    ( but don't have any logging      )
		    ( facilities defined yet.	  )
		}
	    }
	}
    fi
    [ |
;
'rootAcceptLoginsOn export

( =====================================================================	)
( - rootAcceptLogins -- Start allowing user logins on port 30023	)

:   rootAcceptLogins { -> }
    [   .sys$s.muqPort mufVars:_telnetPortOffset +
        'mufVars:_rootNewAccountFn
    | rootAcceptLoginsOn ]pop
;
'rootAcceptLogins export

( Set Muq to accept telnet login when Muq starts in daemon mode: )
'rootAcceptLogins --> .etc.rc2D.s50AllowTelnetLogins


( =====================================================================	)
( - dbfilePerUser setting						)

( buggo, this should really be a parameter to rootMakeAUser, )
( and there should be config menu support for setting it.    )

( By default, put each user in a separate db file: )
t --> me.dbfilePerUser


( =====================================================================	)
( - rootConfigMenu 							)

:   rootConfigMenu { -> }

    "\n+------< Root Config Options >-----\n" ,
    "| u: add a mufshell User\n" ,
    "| l: start allowing telnet Logins\n" ,
    "| m: start Muqnet daemon\n" ,
    "| s: muqnet Status\n" ,
    "| t: Test muqnet daemon\n" ,
    "| n: New-passphrase a user\n" ,
    "| p: change root Passphrase\n" ,
    "| q: Quit this config menu\n" ,
    "+----------------------------------\n" ,
;

( =====================================================================	)
( - rootConfig -- Interactive re/configuration menu.			)
:   rootConfig { -> }

    rootConfigMenu
    do{
	readLine trimString stringDowncase -> choice

	choice case{

	on: "u"
	    "( rootAddUser )\n" ,
	    rootAddUser
            rootConfigMenu

	on: "l"
	    .sys$s.muqPort mufVars:_telnetPortOffset + -> port
	    [ "( [ %d 'mufVars:_rootNewAccountFn | rootAcceptLoginsOn ]pop )\n" port | ]print ,
	    [ port 'mufVars:_rootNewAccountFn | rootAcceptLoginsOn ]pop
	    [ "Now accepting telnet logins on port %d\n" port | ]print ,
	    rootConfigMenu

	on: "m"
	    "( #'muqnet:rootStart )\n" ,
	    muqnet:rootStart
	    .sys$s.muqPort -> port
	    [ "Muqnet daemon started up on port %d\n" port | ]print ,
	    rootConfigMenu

	on: "t"
	    "Enter test string to send:\n" ,
	    .sys$s.muqPort -> port
	    [   :ip0 127 :ip1 0 :ip2 0 :ip3 1 :port port |
	        [ @$s.standardInput '\n' nil |
		    |scanTokenToChar |popp
		    |readTokenChars   |popp
		]|join
		"txt" t .muq$s.muqnetIo
                |writeStreamPacket
		pop pop
	    ]pop
	    rootConfigMenu

	on: "s"
	    [ "Packet count d=%d\n" muqnetVars:_count | ]print ,
	    rootConfigMenu

	on: "n"
	    "( rootChangePassphrase )\n" ,
	    rootChangePassphrase
	    rootConfigMenu

	on: "p"
	    "( changePassphrase )\n" ,
	    changePassphrase
	    rootConfigMenu

	on: "q"   return

	on: ""

	else:
	    "Hrm?\n" ,
        }
    }
;
'rootConfig export


( =====================================================================	)
( - Our config entry							)

"Root Config Options" 'rootConfig addConfigFn

( =====================================================================	)
( - See also rc2 in 14-C-init-shell -					)


( =====================================================================	)
( - Validate muqnet user and user addresses				)

.u  "muqnet" get? pop not if
    "muqnet"
    rootMakeAUser 
fi

( Must be done -after- above: )
rootValidateUserAddresses

( =====================================================================	)

( - Regression test suite support stuff					)

( Establish the global variables: )
0   --> _testNumber
0   --> _bugsFound
nil --> _crashed

: regressionTestReset
  0 --> _testNumber
  0 --> _bugsFound

  nil --> _crashed
;
'regressionTestReset export
: regressionTestReport
  "muf" inPackage
  "\n" ,
  "---------------------\n " ,
  _testNumber , " tests performed.\n " ,
  _bugsFound  ,  " bugs found.\n" ,
  "---------------------\n" ,
;
'regressionTestReport export

( Define a central success-report fn: )
: regressionTestSucc
  "\n+++++ Passed test " , _testNumber , "." ,
;

( Define a central error-report fn: )
: regressionTestFail -> why
  _bugsFound 1 + --> _bugsFound
  "\n***** Failed test " , _testNumber ,
  " because: " , why , ".\n" ,
;

( Define routines to verify success/failure of expressions: )
: shouldFail { $ -> ! } -> x
  _testNumber 1 + --> _testNumber
  stack[ ]pop
  [ :function   :: { -> ! } t --> _crashed   'ncrsh goto ;
    :name 'uncrash
    :reportFunction "Continue from shouldFail"
  | ]withRestartDo{
    [ .e.event ( Catch everything )
      :: { [] -> [] ! } ]pop 'uncrash invokeRestart ;
    | ]withHandlersDo{
      withTag ncrsh do{
	nil --> _crashed
	x call
	ncrsh
	_crashed if                         regressionTestSucc
	else              "Execution didn't fail" regressionTestFail
	fi
  } } }
;
'shouldFail export

: shouldWork { $ -> ! } -> x
  _testNumber 1 + --> _testNumber
  stack[ ]pop
  [ :function   :: { -> ! } t --> _crashed   'ncrsh goto ;
    :name 'uncrash
    :reportFunction "Continue from shouldWork"
  | ]withRestartDo{
    [ .e.event ( Catch everything )
      :: { [] -> [] ! } ]pop 'uncrash invokeRestart ;
    | ]withHandlersDo{
      withTag ncrsh do{
	nil --> _crashed
	x call
	ncrsh
	_crashed if "Execution failed" regressionTestFail
	else                                 regressionTestSucc
	fi
  } } }
;
'shouldWork export

( Define routines to verify results of boolean expressions: )
: shouldBeFalse { $ -> ! } -> x
  _testNumber 1 + --> _testNumber
  stack[ ]pop
  [ :function   :: { -> ! } t --> _crashed   'ncrsh goto ;
    :name 'uncrash
    :reportFunction "Continue from shouldBeFalse"
  | ]withRestartDo{
    [ .e.event ( Catch everything )
      :: { [] -> [] ! } ]pop 'uncrash invokeRestart ;
    | ]withHandlersDo{
      withTag ncrsh do{
	nil --> _crashed
	x call
	ncrsh
	_crashed if "Execution failed" regressionTestFail
        else
	  if   "Didn't return FALSE value" regressionTestFail
	  else                             regressionTestSucc
	  fi
        fi
  } } }
;
'shouldBeFalse export

: shouldBeTrue { $ -> ! } -> x
  _testNumber 1 + --> _testNumber
  stack[ ]pop
  [ :function   :: { -> ! } t --> _crashed   'ncrsh goto ;
    :name 'uncrash
    :reportFunction "Continue from shouldBeTrue"
  | ]withRestartDo{
    [ .e.event ( Catch everything )
      :: { [] -> [] ! } ]pop 'uncrash invokeRestart ;
    | ]withHandlersDo{
      withTag ncrsh do{
	nil --> _crashed
	x call
	ncrsh
	_crashed if "Execution failed" regressionTestFail
        else
	  if                              regressionTestSucc
	  else "Didn't return TRUE value" regressionTestFail
	  fi
        fi
  } } }
;
'shouldBeTrue export

( =====================================================================	)

( - File variables							)


( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
