
( - 310-X-nanomsh.muf -- Example mudUser shell package.		)
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
( Created:      94Sep15							)
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
(  ------------------------------------------------------------------- 	)

( =====================================================================	)
( - Package 'msh', exported symbols --					)

"nanomsh" inPackage
']shell export

( =====================================================================	)
( - Quotation.								)
(									)
( "In addition to scientists and philosophers, Harun al-Rashid		)
(  also patronized singers and poets.  To one poet who composed		)
(  a sonnet in his honor he gave five thousand gold pieces, a		)
(  robe of honor, ten Greek slave girls, and one of his best horses."	)
(									)
(  -- A History of the Middle Ages (Joseph Dahmus) p188.		)
(									)
( =====================================================================	)

( =====================================================================	)
( - Overview --								)

( This file implements a simple user shell for the Muq nanomud.		)
( The design intention is that Muq should support multiple user		)
( shells implementing different user interface preferences and		)
( also multiple world implementations, and that every user shell	)
( should work with every world implementation.				)
(									)
( The protocol for fully implementing this ambition remains to be	)
( defined, but separating 90-mud.muf from 91-msh.muf provides at	)
( least a first step down this path.					)

( =====================================================================	)
( - Epigram.								)

(  In the long run, there are only two kinds of muds:		 	)
(  Distributed muds, and dead muds.				     	)

( =====================================================================	)

( - Public fns ---							)


( =====================================================================	)
( - doView -- Look around						)

:   doView { $ $ -> }
    -> avatar
    -> world

    ( Show room description proper: )
    avatar nanomud:describeLocation "\n" ,

    ( List all visible exits in room: )
    nil -> doneHeader
    avatar nanomud:getLocationExits[
	|for x do{
	    doneHeader not if
		"Obvious exits:" ,
		t -> doneHeader
	    fi
	    " " , x ,
	}
    ]pop
    doneHeader if "\n" , fi

    ( List all listeners in room, except self: )
    nil -> doneHeader
    avatar nanomud:getLocationListeners[
	|for a do{
	    a avatar != if
		doneHeader not if
		    "Listening:" ,
		    t -> doneHeader
		fi
		" " , a.name ,
	    fi
	}
    ]pop
    doneHeader if "\n" , fi
;

( =====================================================================	)
( - doMuf -- Compile and execute a line of muf				)

:   doMuf { $ $ $ $ -> ! }
    -> muf
    -> inputLine
    -> avatar
    -> world

    ( Start compile: )
    inputLine muf startMufCompile

    ( Provide standard hook for killing job: )
    [ :function :: { -> ! } nil endJob ;
      :name 'muf:endJob
      :reportFunction "Terminate job."
    | ]withRestartDo{

	( We want to trap compile errors etc: )
	[ :function :: { -> ! } 'muf:abrt goto ;
	  :name 'muf:abort
	  :reportFunction "return to main mudShell prompt."
	| ]withRestartDo{
	    withTag muf:abrt do{                ( Trap compile errs etc    )

		( Loop that runs until we have a complete expression: )
		do{

		    ( Loop that runs until current line is compiled: )
		    do{ muf continueMufCompile until } if

			( We have compiled a complete expression: )

			( Execute compiled function: )
			call	

			( Display datastack: )
			"Stack: " , print1DataStack , "\n" ,

			return

		    else

			,		    ( Prompt for more muf source.    )
			readLine	    ( Read more muf source.	     )
			muf addMufSource  ( Feed added source to compiler. )
		    fi
		}


		abrt                         ( Continuation from errors )
	    }
	}
    }
;

( =====================================================================	)
( - ]doGo -- Go somewhere						)

:   ]doGo { [] $ $ -> }
    -> avatar
    -> world

    ( Drop ',g ' prefix off input line: )
    do{
        |shift whitespace? not while
    }
    ]join -> inputLine

    ( Invoke world 'move' command with remainder: )
    avatar inputLine nanomud:move , pop

    ( View new room: )
    world avatar doView
;

( =====================================================================	)
( - ]doPose -- Send string to all listeners at current location	)

:   ]doPose { [] $ $ -> }
    -> avatar
    -> world

    ( Echo to ourself first: )
    avatar.name vals[ ' ' |push
	"txt" nil @.standardOutput 
	|writeStreamPacket
	pop pop
    ]pop
    "txt" nil @.standardOutput 
    |writeStreamPacket
    pop pop
    [ '\n' |
	"txt" t @.standardOutput 
	|writeStreamPacket
	pop pop
    ]pop

    ( Rehack inputLine into appropriate 'pose' format: )
    '\n' |push
    ' '  |unshift
    ]evec -> text

    ( Over all listeners in room, except self.         )
    ( NB:  We do not use nanomud:notifyExcept         )
    ( because we don't trust mudworld implementor not  )
    ( to add unwanted listeners.  Ideally we would     )
    ( verify that listeners never appear or disappear  )
    ( unannounced.                                     )
    avatar nanomud:getLocationListeners[
	|for a do{
	    a avatar != if
		text vals[
		    avatar t a.standardInput
		    |maybeWriteStreamPacket
		    pop pop
		]pop
	    fi
	}
    ]pop
;

( =====================================================================	)
( - ]doSay -- Send string to all listeners at current location		)

:   ]doSay { [] $ $ -> }
    -> avatar
    -> world

    ( Echo to ourself first: )
    "You say, \"" vals[ 
	"txt" nil @.standardOutput 
	|writeStreamPacket
	pop pop
    ]pop
    "txt" nil @.standardOutput 
    |writeStreamPacket
    pop pop
    "\"\n" vals[
	"txt" t @.standardOutput 
	|writeStreamPacket
	pop pop
    ]pop

    ( Rehack inputLine into appropriate 'say' format: )
    '"'  |push
    '\n' |push
    '"'  |unshift
    ' '  |unshift
    ','  |unshift
    's'  |unshift
    'y'  |unshift
    'a'  |unshift
    's'  |unshift
    ]evec -> text

    ( Over all listeners in room, except self.         )
    ( NB:  We do not use nanomud:notifyExcept         )
    ( because we don't trust mudworld implementor not  )
    ( to add unwanted listeners.  Eventually we will   )
    ( verify that listeners never appear or disappear  )
    ( unannounced.                                     )
    avatar nanomud:getLocationListeners[
	|for a do{
	    a avatar != if
		text vals[
		    avatar t a.standardInput
		    |maybeWriteStreamPacket
		    pop pop
		]pop
	    fi
	}
    ]pop
;

( =====================================================================	)
( - printHelp -- Quick help summary.					)

:   printHelp { -> } 

    "\n" ,
    "Quick help for Muq nanomud\n" ,
    "--------------------------\n" ,
    "'.g exit' -- Go through exit 'exit'.\n" ,
    "'.help'   -- Print this help.\n" ,
    "'.view'   -- View room.\n" ,
    "'.quit'   -- Disconnect from mud.\n" ,
    "'<text>'  -- Roommates see '<yourname> says, \"<text>\"\n" ,
    "' <text>' -- Roommates see '<yourname> <text>\n" ,
    "',<code>' -- Run muf <code>.\n" ,
;

( =====================================================================	)
( - printHmm -- Print pointer to help.					)

:   printHmm { -> } 
    "Hmm?   (Do '.help' for help.)\n" ,
;

( =====================================================================	)
( - ]shell -- Toplevel mud shell loop.					)

:   ]shell { [] -> @ }
        :avatar |get -> avatar
        :world  |get -> world
    ]pop

    world$s.owner -> worldOwner

    @.jobSet.session.socket -> ourSocket

    ( Allow others to write to our instream: )
    t --> @.standardInput.twin.allowWrites

    @.standardInput.twin --> avatar.standardInput

    avatar nanomud:welcomeUser
    "Do '.help' for help.\n" ,

    makeFunction makeMuf -> muf
    world avatar doView

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

    ( Establish a handler letting users   )
    ( abort a job with a signal           )
    ( -- via 'abortJob' say:             )
    [ .e.abort :: { [] -> [] ! } 'abort invokeRestart ;
    | ]withHandlerDo{               ( 4 )

    ( Establish a handler that will kill  )
    ( us if we lose the net link:         )
    [ .e.brokenPipeWarning :: { [] -> [] ! } nil endJob ;
    | ]withHandlerDo{               ( 5 )

    withTag muf:abrt do{       ( 6 ) ( Trap compile errs etc    )
    abrt                          ( Continuation from errors )
    (       -- END BOILERPLATE --         )


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




    do{
	( Read one unprompted line from input stream: )
	t @.standardInput readStreamPacket[ -> who -> tag


	( Check for special input messages  )
	( flagging another avatar's connect )
	( or such in our room:              )
	tag case{

	on: :connect
	    ( We flag connect messages with )
	    ( a leading '[' to prevent folk )
	    ( spoofing them effectively:    )
	    who worldOwner != if ]pop loopNext fi
	    ]-> anAvatar
            [ "[ %s has connected.\n" anAvatar.name | ]print ,
	    loopNext

	on: :disconnect
	    ( We flag disconnect messages   )
	    ( with a leading ']' to prevent )
	    ( effective spoofing of them:   )
	    who worldOwner != if ]pop loopNext fi
	    ]-> anAvatar
            [ "] %s has disconnected.\n" anAvatar.name | ]print ,
	    loopNext

	on: :arrive
	    ( We flag arrival messages with )
	    ( a leading '<' to prevent folk )
	    ( spoofing them effectively:    )
	    who worldOwner != if ]pop loopNext fi
	    ]-> anAvatar
            [ "< %s has arrived.\n" anAvatar.name | ]print ,
	    loopNext

	on: :depart
	    ( We flag departure msgs with   )
	    ( a leading '>' to prevent folk )
	    ( spoofing them effectively:    )
	    who worldOwner != if ]pop loopNext fi
	    ]-> anAvatar
            [ "> %s has left.\n" anAvatar.name | ]print ,
	    loopNext

	on: "txt"

	    ( Ignore packets not from our socket: )
	    who ourSocket != if ]pop loopNext fi

	    ( Ignore empty packets: )
	    |length 0 = if ]pop loopNext fi

	    ( If line has a leading comma treat )
	    ( it as mufcode to compile and run: )
	    0 |dupNth ',' = if
		|shiftp ]join -> inputLine
		world avatar inputLine muf doMuf
		loopNext
	    fi

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


	    ( Treat leading whitespace as pose commands: )
	    leadingWhitespace if
		world avatar ]doPose
		loopNext
	    fi

	    ( Get first nonblank character from input line: )
	    0 |dupNth -> char0

	    ( Treat alphabetics as say commands: )
	    char0 alphaChar? if
		world avatar ]doSay
		loopNext
	    fi

	    ( Treat '.' as cue to do special commands: )
	    char0 '.' = if
		|length 1 > if

		    ( Key on next character: )
		    1 |dupNth -> char1

		    char1 case{	
		    on: 'g'   world avatar ]doGo
		    on: 'h'   ]pop printHelp
		    on: 'v'   ]pop world avatar doView
		    on: 'q'   ]pop world avatar nanomud:quit
		    else:     ]pop printHmm
		    }
		fi
		loopNext
	    fi

	    ]pop printHmm

	else:
	    ( Ignore other packet type other than avatar: )
	    tag nanomud:avatar? not if ]pop loopNext fi

	    ( Should be a say or pose from another user. )
	    ( Ignore say or pose unless from owner of    )
	    ( avatar, to discourage spoofing:            )
	    tag$s.owner who != if ]pop loopNext fi

	    ( Ignore say or pose from avatars not in	 )
	    ( our world:                                 )
	    tag.world world != if ]pop loopNext fi

	    ( Drop any non-char garbage in packet: )
	    |deleteNonchars

	    ( Drop leading whitespace: )
	    do{
		|length 0 = until
		0 |dupNth whitespace? not until
		|shiftp
	    }

	    ( Drop trailing whitespace: )
	    do{
		|length 0 = until
		|length 1- |dupNth whitespace? not until
		|popp
	    }

	    ( Write name of avatar followed by )
	    ( blank, as an incomplete packet:  )
	    tag.name vals[ ' ' |push
		"txt" nil @.standardOutput 
		|writeStreamPacket
		pop pop
	    ]pop

	    ( Write text of message plus  )
	    ( a final newline, completing )
	    ( the packet:                 )
	    '\n' |push
	    "txt" t @.standardOutput
	    |writeStreamPacket
	    pop pop
	    ]pop
	}
    }

    } ( 8 )
    } ( 7 )
    } ( 6 )
    } ( 5 )
    } ( 4 )
    } ( 3 )
    } ( 2 )
    } ( 1 )
;

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)


