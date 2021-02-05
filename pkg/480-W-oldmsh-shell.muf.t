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

( - 480-W-oldmsh-shell.muf -- Mud-user shell package for 330-W-oldmud.	)
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
( Created:      96Oct21, from 31-X-nanomsh.t				)
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
(  ------------------------------------------------------------------- 	)

( =====================================================================	)
( - Package 'msh', exported symbols --					)

"oldmsh" inPackage

( =====================================================================	)
( - Quotation.								)
(									)
(    "Our business is to make raids on the enemy,			)
(     on our neighbor, and on our brother, in case			)
(     we find none to raid but a brother."				)
(									)
(	-- Medieval Arab poet						)
(          quoted in History of the Arabs (Philip Hitti) p25		)
(									)
( =====================================================================	)

( =====================================================================	)
( - Overview --								)


( =====================================================================	)

( - Classes ---								)

defclass: shellState
    :export t

    :slot :opNames	:prot "rw----"	:initform  :: makeStack ;
    :slot :opIt		:prot "rw----"	:initform  :: makeStack ;
;

( =====================================================================	)

( - Vanilla functions ---						)

( =====================================================================	)
( - doEnholding -- Ask our daemon to have THIS hold THAT:		)

:   doEnholding { $ $ $ -> }
    -> that
    -> this
    -> av

    [   :op 'oldmud:REQ_ENHOLDING
        :to this
        :a0 that
	:am "oldmsh/doEnholding/REQ_ENHOLDING"
        :fn ::  { [] -> [] }
	    |shift -> taskId	( 					)
	    |shift -> from	( 					)
	    |shift -> this	( to					)
	    |shift -> that	( a0					)
	    |shift -> err	( Return val from doReqEnholding	)
	    ]pop

	    ( Send status report to user shell: )
	    @.task.taskState -> av
	    err if   err errcho   [ | return   fi

	    "succeeded!" vals[
		"ehd" t av.userIo
		|maybeWriteStreamPacket
		pop pop
	    ]pop

	    [ |
	;
    |   ]request
;

( =====================================================================	)
( - doEnheldBy -- Ask our daemon to have THIS heldBy THAT:		)

:   doEnheldBy { $ $ $ -> }
    -> that
    -> this
    -> av

    [   :op 'oldmud:REQ_ENHELD_BY
        :to this 
        :a0 that
        :fn ::  { [] -> [] }
	    |shift -> taskId	( 					)
	    |shift -> from	( 					)
	    |shift -> this	( to					)
	    |shift -> that	( a0					)
	    |shift -> err	( Return val from doReqEnheldBy	)
	    ]pop

	    ( Send status report to user shell: )
	    @.task.taskState -> av
	    err if  err errcho   [ |   return fi

	    "succeeded!" vals[
		"ehb" t av.userIo
		|maybeWriteStreamPacket
		pop pop
	    ]pop

	    [ |
	;
    |   ]request
;

( =====================================================================	)
( - enterShellCommand -- 						)

:   enterShellCommand { $ $ -> }
    -> cc	( mshCommand class	  )
    -> ss	( Instance of shellState )

    ss.opNames -> n
    ss.opIt    -> i

    cc makeInstance   -> it
    [ it |  cmdNames
        |for name do{
	    name n push
	    it   i push
	}
    ]pop
;

( =====================================================================	)
( - makeShellState -- 							)

:   makeShellState { -> $ }

    'shellState makeInstance -> ss

    ( Define commands implemented by avatar shell: )
    ss 'cmdGo          enterShellCommand
    ss 'cmdHelp	       enterShellCommand
    ss 'cmdLook        enterShellCommand
    ss 'cmdPage        enterShellCommand
    ss 'cmdPose        enterShellCommand
    ss 'cmdSay         enterShellCommand
    ss 'cmdWhisper     enterShellCommand
    ss 'cmdBan         enterShellCommand
    ss 'cmdBoot        enterShellCommand
    ss 'cmdDig         enterShellCommand
    ss 'cmdDoing       enterShellCommand
    ss 'cmdEject       enterShellCommand
    ss 'cmdGag         enterShellCommand
    ss 'cmdHide        enterShellCommand
    ss 'cmdHome        enterShellCommand
    ss 'cmdInside      enterShellCommand
    ss 'cmdMuf         enterShellCommand
    ss 'cmdOutside     enterShellCommand
    ss 'cmdPing        enterShellCommand
    ss 'cmdQuit        enterShellCommand
    ss 'cmdRepeat      enterShellCommand
    ss 'cmdRestart     enterShellCommand
    ss 'cmdShort       enterShellCommand
    ss 'cmdState       enterShellCommand
    ss 'cmdWho         enterShellCommand

    ss
;
'makeShellState export


( =====================================================================	)
( - welcome -- Welcome user to mudshell.				)

:   welcome { -> }

    "Welcome to the Muq oldmud shell!  (Do 'help' for help.)\n" ,
;

( =====================================================================	)
( - printHmm -- Print pointer to help.					)

:   printHmm { -> } 
    "Hmm?   (Do 'help' for help.)\n" ,
;

( =====================================================================	)
( - ]shell -- Toplevel mud shell loop.					)

:   ]shell { [] -> @ }
        :avatar |get -> av
    ]pop

"+++oldmsh-shell invoked...\n" log,
    av.shellState.opNames -> opn
    av.shellState.opIt    -> opi

    @.jobSet.session.socket -> ourSocket

( Allow others to write to our instream: )
t --> @.standardInput.twin.allowWrites	( buggo! )
t --> @.standardInput.twin.allowReads	( buggo! )
t --> @.standardInput.allowWrites		( buggo! )
t --> @.standardInput.allowReads		( buggo! )

    ( Publish our input queue so our user daemon can find it: )
    @.standardInput.twin --> av.userIo

    ( Log as well as report errors.         )
    ( Buggo, may not want to log user shell )
    ( errors in production releases:        )
    'muf:reportAndLogEvent --> @.reportEvent

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
	:reportFunction "Return to main mudShell prompt."
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
    (       -- SUSPEND BOILERPLATE --     )

    ( Following stuff isn't as standard   )
    ( as the above in my mind, but still  )
    ( is set up to match mufShell:       )

    ( Establish a handler that will print )
    ( active jobs on .etc.printJobs:     )
    [ .e.printJobs :: { [] -> [] ! } printJobs ;
    | ]withHandlerDo{               ( 7 )
    
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
    | ]withHandlerDo{               ( 8 )

    ( Configure socket to generate an    )
    ( .e.debug signal on ^Y:           )
    sock 25 .e.debug setSocketCharEvent




    ( Start up telnet daemon if we're on a )
    ( netlink and none is running:         )
    telnet:maybeStartTelnetDaemon

    ( Publish task service: )
    av.daemonTask --> @.task

    av.daemonJob jobIsAlive? not if
	"Note: YOUR AVATAR DAEMON IS DEAD.  ('@restart' restarts it.)\n" ,
    else
	( If avatar isn't currently in )
	( any room, go to home room:   )
	[ av | oldmud:numberHeldBy ]shift 0 = if
	    [ av.thisRoomCache av av.homeRoom | oldmud:enterRoom ]pop
	fi
    fi

    [ av | oldmud:noteWhoUserConnect ]pop

    ( Note date of last garbage collect and backup: )
    .muq.dateOfLastGarbageCollect -> lastGc
    .muq.dateOfLastBackup         -> lastBackup

    ( Notify user we're up: )
    welcome


    (       -- RESUME BOILERPLATE --      )
    "oldmsh:]shell starting up.\n" log,
    withTag muf:abrt muf:exitShell do{       ( 9 ) ( Trap compile errs etc    )
    abrt                          ( Continuation from errors )
    (       -- END BOILERPLATE --         )


    do{
	( Inform user if a gc or backup has been done: )
	.muq.dateOfLastGarbageCollect -> d
	d lastGc != if
	    [   "* %g-sec garbage collect %g secs ago freed %d bytes, %d blocks.\n"
	        .muq.millisecsForLastGarbageCollect 0.001 *
	        .sys.millisecsSince1970 d -         0.001 *
	        .muq.bytesRecoveredInLastGarbageCollect
	        .muq.blocksRecoveredInLastGarbageCollect
	    |   ]print ,
	    d -> lastGc
	fi
	.muq.dateOfLastBackup -> d
	d lastBackup != if
	    [   "* Backup done %g secs ago, took %g secs.\n"
	        .sys.millisecsSince1970 d -  0.001 *
	        .muq.millisecsForLastBackup  0.001 *
	    |   ]print ,
	    d -> lastBackup
	fi

	( Read one unprompted line from input stream: )
	t @.standardInput readStreamPacket[ -> who -> tag

	tag integer? if
	    |length 0 = if
		]pop loopNext
	    fi
	    |shift -> id
	fi

	tag case{
	on: "eko"
	    ( Anything not from our own daemon is a spoof: )
(	    who me != if ]pop loopNext fi )
	    '\n' |push
            |deleteNonchars
            "txt" t @.standardOutput
            |writeStreamPacket
            pop pop ]pop
	    loopNext

	on: "txt"

	    ( Ignore packets not from our socket: )
	    who ourSocket != if ]pop loopNext fi

	    ( Ignore empty packets: )
	    |length 0 = if ]pop loopNext fi

	    [ av | oldmud:noteWhoUserActivity ]pop

	    ( Drop leading whitespace: )
	    nil -> leadingWhitespace
	    do{
		|length 0 = until
		0 |dupNth whitespace? not until
		|shiftp
		t -> leadingWhitespace
	    }

	    ( Drop trailing whitespace: )
	    do{
		|length 0 = until
		|length 1- |dupNth whitespace? not until
		|popp
	    }

	    ( Ignore allBlank packets: )
	    |length 0 = if ]pop loopNext fi


	    ( Get first nonblank character from input line: )
	    0 |dupNth -> char0

	    ( Treat " and ' and leading whitespace as say commands: )
	    leadingWhitespace if
		' ' |unshift
		's' |unshift
		's' -> char0
	    fi
	    char0 '"'  = 
	    char0 '\'' =
            or if
		|shiftp
		' ' |unshift
		's' |unshift
	    fi

	    ( Treat : ; and . as pose commands: )
	    char0 ':' =
	    char0 ';' =
	    char0 '.' =
            or or if
		|shiftp
		' ' |unshift
		'p' |unshift
	    fi

	    ( Handle escapes: )
	    |backslashesToHighbit

	    ( Extract first word of commandline: )
	    " " |charPosition -> pos
	    pos if
		++ pos
		0 pos |extract[ |popp
	    else
		|length 0 swap |extract[
	    fi

	    ( Look up word: )
	    opn |positionInStack? -> i if

		( It is a defined command, execute it: )
(		]pop )
(		[ opi[i] av opn[i] | cmdDo ]pop )
		]pop
		opn[i] |unshift
		av     |unshift
		opi[i] |unshift
		cmdDo ]pop
		loopNext
	    fi

	    ]pop
	    ]pop printHmm

        }
    }

    exitShell                    ( Exit from shell          )
    "oldmsh:]shell exiting up.\n" log,
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
']shell export

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
