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

( - 070-C-telnet.muf -- TELNET procotol support.				)
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
( Created:      95Oct28							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1996, by Jeff Prothero.				)
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

(	The bourgeoisie, by the rapid improvement of all		)
(	instruments of production, by the immensely			)
(	facilitated means of communication, draws all,			)
(	even the most barbarian, nations into civilization.		)
(			-- Karl Marx, The Communist Manifesto		)

( =====================================================================	)
( - Forward declarations						)

me$s.lib["muf"] "forkJobset" get? pop not if
    "muf" inPackage
    'forkJobset export
    :: { -> $ ! } ; --> #'forkJobset
fi
me$s.lib["muf"] "abortJob" get? pop not if
    "muf" inPackage
    'abortJob export
    :: { $ -> ! } ; --> #'abortJob
fi

"TLNT" rootValidateDbfile pop
[ "telnet" .db["TLNT"] | ]inPackage
( "telnet" inPackage )
me$s.lib["telnet"] --> .lib["telnet"]

( =====================================================================	)
( - Constants								)

( We need names for the major TELNET byte values:    )
255 intChar -->constant isACommand
254 intChar -->constant dont
253 intChar -->constant do
252 intChar -->constant wont
251 intChar -->constant will
250 intChar -->constant suboptionBegin
249 intChar -->constant goAhead
( 248 intChar -->constant eraseLine )
( 247 intChar -->constant eraseCharacter )
246 intChar -->constant areYouThere
245 intChar -->constant abortOutput
244 intChar -->constant interruptProcess
243 intChar -->constant telnetBreak
242 intChar -->constant dataMark
241 intChar -->constant nop
240 intChar -->constant suboptionEnd

( Also names for the TELNET options: )
  0 -->constant transmitBinary
  1 -->constant echo
  3 -->constant suppressGoAhead


( Some additional internal opcodes not part )
( of the TELNET standard, which we use to   )
( accept commands from other Muq jobs:      )
154 intChar -->constant wantDont
153 intChar -->constant wantDo
152 intChar -->constant wantWont
151 intChar -->constant wantWill


( We need to maintain a state for each negotiable    )
( telnet option at each end of the link, which we do )
( in the strings socket.thisTelnetState and      )
( socket.thatTelnetState.                        )

( bit 0 == THIS QUEUE: 0==Empty 1=Opposite )
( bit 1 == THIS YES/NO 0==No    1=Yes      )
( bit 2 == THIS WANT : 0==-     1=Want     )
 0 intChar -->constant stateN
 2 intChar -->constant stateY
 4 intChar -->constant stateWne
 5 intChar -->constant stateWno
 6 intChar -->constant stateWye
 7 intChar -->constant stateWyo

'stateY export 

( =====================================================================	)
( - Functions								)

( =====================================================================	)
( - dataMarkFn		             				)

:   dataMarkFn { $ $ $ -> } -> that -> this -> oobInput 
;

( =====================================================================	)
( - breakFn			             				)

:   breakFn { $ $ $ -> } -> that -> this -> oobInput 
;

( =====================================================================	)
( - interruptProcessFn -- Send abort signal to session leader		)

:   interruptProcessFn { $ $ $ -> } -> that -> this -> oobInput 
    @.jobSet.session.sessionLeader -> sessionLeader
    [ :event .e.abort :job sessionLeader | ]signal
;

( =====================================================================	)
( - abortOutputFn -- Discard data headed for net			)

:   abortOutputFn { $ $ $ -> } -> that -> this -> oobInput 
    @.jobSet.session.socket -> socket
    t --> socket.discardNetboundData
    ( Buggo, should send a telnet Synch signal )
    ( here, according to RFC 854.              )
;

( =====================================================================	)
( - areYouThereFn		             				)

:   areYouThereFn { $ $ $ -> } -> that -> this -> oobInput 
    @.jobSet.session.sessionLeader -> sessionLeader
    [ :event .e.printJobs :job sessionLeader | ]signal
;

( =====================================================================	)
( - goAheadFn			             				)

:   goAheadFn { $ $ $ -> } -> that -> this -> oobInput 
;

( =====================================================================	)
( - sendDont			             				)

:   sendDont { $ $ -> } intChar -> code -> oobInput 
    [ isACommand dont code |
    "txt" t oobInput
    |writeStreamPacket
    pop pop ]pop
;

( =====================================================================	)
( - sendWont			             				)

:   sendWont { $ $ -> } intChar -> code -> oobInput 
    [ isACommand wont code |
    "txt" t oobInput
    |writeStreamPacket
    pop pop ]pop
;

( =====================================================================	)
( - sendWill			             				)

:   sendWill { $ $ -> } intChar -> code -> oobInput 
    [ isACommand will code |
    "txt" t oobInput
    |writeStreamPacket
    pop pop ]pop
;

( =====================================================================	)
( - sendDo			             				)

:   sendDo { $ $ -> } intChar -> code -> oobInput 
    [ isACommand do code |
    "txt" t oobInput
    |writeStreamPacket
    pop pop ]pop
;

( =====================================================================	)
( - The Q-machine state transition table at a glance.			)

 ( Following is based on the Q method from )
 ( http://ds.internic.net/rfc/rfc1143.txt: )

 ( ==================================================================== )
 ( Legend:   N=No   Y=Yes    E=Empty     WY=WantYes       WN=WantNo     )
 ( Left state column: Old state.     Right state column: New state.     )
 ( ==================================================================== )
 ( Reading WONT:  || Reading WILL:  || WANT-DONT:     || WANT-DO:       )
 ( THAT SEND THAT || THAT SEND THAT || THAT SEND THAT || THAT SEND THAT )
 ( ---- ---- ---- || ---- ---- ---- || ---- ---- ---- || ---- ---- ---- )
 (  N             ||  N   DONT      ||                ||                )
 (  N             ||  N   DO    Y   ||  N   err       ||  N   DO   WY   )
 (  Y   DONT  N   ||  Y             ||  Y   DONT WN   ||  Y   err       )
 ( WN E       N   || WN E err   N   || WN E err       || WN E         O )
 ( WN O DO   WY E || WN O err   Y E || WN O         E || WN O err       )
 ( WY E       N   || WY E       Y   || WY E         O || WY E err       )
 ( WY O DONT  N E || WY O DONT WN E || WY O err       || WY O         E )
 ( ==================================================================== )
 (    DO<->WILL   DONT<->WONT   MIRROR   THIS<->THAT   THISQ<->THATQ    )
 ( ==================================================================== )
 ( Reading DONT:  || Reading DO:    || WANT-WONT:     || WANT-WILL:     )
 ( THIS SEND THIS || THIS SEND THIS || THIS SEND THIS || THIS SEND THIS )
 ( ---- ---- ---- || ---- ---- ---- || ---- ---- ---- || ---- ---- ---- )
 (  N             ||  N   WONT      ||                ||                )
 (  N             ||  N   WILL  Y   ||  N   err       ||  N   WILL WY   )
 (  Y   WONT  N   ||  Y             ||  Y   WONT WN   ||  Y   err       )
 ( WN E       N   || WN E err   N   || WN E err       || WN E         O )
 ( WN O WILL WY E || WN O err   Y E || WN O         E || WN O err       )
 ( WY E       N   || WY E       Y   || WY E         O || WY E err       )
 ( WY O WONT  N E || WY O WONT WN E || WY O err       || WY O         E )
 ( ==================================================================== )


( =====================================================================	)
( - ]supportedOptionHandler						)

:   ]supportedOptionHandler { [] $ $ $ $ $ -> }

    -> op   ( One of will wont do dont suboptionBegin )
    -> code ( Integer, 0-255                           )
    -> that ( 256-byte state-* string                  )
    -> this ( 256-byte state-* string                  )
    -> oob  ( Out-Of-Band message stream for replies   )

    ( This handler is intended to do the busywork for     )
    ( negotiating state changes for a supported option,   )
    ( without actually doing anything option-specific.    )
    ( It is intended to be a straightforward implement-   )
    ( ation of the Q-machine transition table above:      )
    op case{

    on: wont          ]pop
	( Reading WONT:  ) 
	( THAT SEND THAT )
	( ---- ---- ---- )
	(  N             ) that[code] case{                                             
	(  N             ) on: stateN    ( Nothing to do. )                           
	(  Y   DONT  N   ) on: stateY    oob code sendDont stateN   --> that[code]
	( WN E       N   ) on: stateWne                     stateN   --> that[code]
	( WN O DO   WY E ) on: stateWno  oob code sendDo   stateWye --> that[code]
	( WY E       N   ) on: stateWye                     stateN   --> that[code]
	( WY O DONT  N E ) on: stateWyo  oob code sendDont stateN   --> that[code]
        ( ============== ) }                                                            
        
        
    on: will          ]pop
	( Reading WILL:  )
	( THAT SEND THAT )
	( ---- ---- ---- )
	(  N   DONT      ) that[code] case{                                             
	(  N   DO    Y   ) on: stateN    oob code sendDo   stateY   --> that[code]
	(  Y             ) on: stateY    ( Nothing to do. )
	( WN E err   N   ) on: stateWne                     stateN   --> that[code]
	( WN O err   Y E ) on: stateWno                     stateY   --> that[code]
	( WY E       Y   ) on: stateWye                     stateY   --> that[code]
	( WY O DONT WN E ) on: stateWyo  oob code sendDont stateWne --> that[code]
        ( ============== ) }                                                            
        
    on: dont          ]pop
	( Reading DONT:  )
	( THIS SEND THIS )
	( ---- ---- ---- )
	(  N             ) this[code] case{                                             
	(  N             ) on: stateN    ( Nothing to do. )                          
	(  Y   WONT  N   ) on: stateY    oob code sendWont stateN   --> this[code]
	( WN E       N   ) on: stateWne                     stateN   --> this[code]
	( WN O WILL WY E ) on: stateWno  oob code sendWill stateWye --> this[code]
	( WY E       N   ) on: stateWye                     stateN   --> this[code]
	( WY O WONT  N E ) on: stateWyo  oob code sendWont stateN   --> this[code]
        ( ============== ) }                                                            
        
    on: do            ]pop
	( Reading DO:    )
	( THIS SEND THIS )
	( ---- ---- ---- )
	(  N   WONT      ) this[code] case{                                             
	(  N   WILL  Y   ) on: stateN    oob code sendWill stateY   --> this[code]
	(  Y             ) on: stateY                                                
	( WN E err   N   ) on: stateWne                     stateN   --> this[code]
	( WN O err   Y E ) on: stateWno                     stateY   --> this[code]
	( WY E       Y   ) on: stateWye                     stateY   --> this[code]
	( WY O WONT WN E ) on: stateWyo  oob code sendWont stateWne --> this[code]
        ( ============== ) }                                                            
        
    on: wantDont     ]pop
        ( WANT-DONT:     )
	( THAT SEND THAT )
	( ---- ---- ---- )
	(                ) that[code] case{                                           
	(  N   err       ) on: stateN                                                
	(  Y   DONT WN   ) on: stateY    oob code sendDont stateWne --> that[code]
	( WN E err       ) on: stateWne                                              
	( WN O         E ) on: stateWno                     stateWne --> that[code]
	( WY E         O ) on: stateWye                     stateWno --> that[code]
	( WY O err       ) on: stateWyo                                               
        ( ============== ) }                                                            

    on: wantDo       ]pop
        ( WANT-DO:       )
	( THAT SEND THAT )
	( ---- ---- ---- )
	(                ) that[code] case{                                           
	(  N   DO   WY   ) on: stateN    oob code sendDo   stateWye --> that[code]
	(  Y   err       ) on: stateY                                                
	( WN E         O ) on: stateWne                     stateWno --> that[code]
	( WN O err       ) on: stateWno                                              
	( WY E err       ) on: stateWye                                              
	( WY O         E ) on: stateWyo                     stateWye --> that[code]
        ( ============== ) }                                                            

    on: wantWont     ]pop
        ( WANT-WONT:     )
	( THIS SEND THIS )
	( ---- ---- ---- )
	(                ) this[code] case{                                           
	(  N   err       ) on: stateN                                                
	(  Y   WONT WN   ) on: stateY    oob code sendWont stateWne --> this[code]
	( WN E err       ) on: stateWne                                              
	( WN O         E ) on: stateWno                     stateWne --> this[code]
	( WY E         O ) on: stateWye                     stateWno --> this[code]
	( WY O err       ) on: stateWyo                                              
        ( ============== ) }                                                            

    on: wantWill     ]pop
        ( WANT-WILL:     )
	( THIS SEND THIS )
	( ---- ---- ---- )
	(                ) this[code] case{                                           
	(  N   WILL WY   ) on: stateN    oob code sendWill stateWye --> this[code]
	(  Y   err       ) on: stateY                                                
	( WN E         O ) on: stateWne                     stateWno --> this[code]
	( WN O err       ) on: stateWno                                              
	( WY E err       ) on: stateWye                                              
	( WY O         E ) on: stateWyo                     stateWye --> this[code]
        ( ============== ) }                                                            

    on: suboptionBegin
	]pop
	( Ignored. )

    else:
        ]pop
    }
;
']supportedOptionHandler export

( =====================================================================	)
( - ]unsupportedOptionHandler						)

:   ]unsupportedOptionHandler { [] $ $ $ $ $ -> }

    -> op        ( One of will wont do dont suboptionBegin )
    -> code      ( Integer, 0-255                           )
    -> that      ( 256-byte state-* string                  )
    -> this      ( 256-byte state-* string                  )
    -> oobInput ( Message stream for replies               )
    ]pop

    ( This is the handler called for unsupported options. )
    ( We always refuse DO and WILL, and always ignore     )
    ( everything else:                                    )
    op case{
    on: will              oobInput code sendDont
    on: do	          oobInput code sendWont
    on: wont              ( Ignored. )
    on: dont              ( Ignored. )
    on: wantWont         ( Ignored. )
    on: wantDont         ( Ignored. )
    on: wantDo           ( Ignored. )
    on: wantDont         ( Ignored. )
    on: suboptionBegin	  ( Ignored. )
    }
;
']unsupportedOptionHandler export

( =====================================================================	)
( - want			             				)

:   want { $ $ $ -> }

    -> op     ( One of wantWont wantDont wantWill wantDo )
    -> code   ( Integer in 0-255 )
    -> socket ( Socket on which to hack option. )

    ( Assume this is an entrypoint for lots of )
    ( clueless users, and do oodles of sanity  )
    ( checks, trying to issue helpful msgs:    )

    socket isASocket

    code   isAnInteger
    code 0   < if "option code must be >= 0"  simpleError fi
    code 255 > if "option code must be < 256" simpleError fi

    socket.telnetProtocol not if
	"Telnet protocol not selected on socket (see telnet:start)" simpleError
    fi

    socket.outOfBandInput -> oobInput
    oobInput messageStream? not if
	"No outOfBandInput on socket (see telnet:start)" simpleError
    fi

    socket.thisTelnetState -> this
    socket.thatTelnetState -> that
    this string? not if
	"No thisTelnetState on socket (see telnet:start)" simpleError
    fi
    that string? not if
	"No thatTelnetState on socket (see telnet:start)" simpleError
    fi

    socket.outOfBandJob job? not if
	"No outOfBandJob running on socket (see telnet:start)" simpleError
    fi

    socket.telnetOptionLock -> lock
    lock lock? not if
	"No telnetOptionLock on socket (see telnet:start)" simpleError
    fi

    socket.telnetOptionHandler -> handlers
    handlers vector? not if
	"No telnetOptionHandler vector on socket (see telnet:start)" simpleError
    fi
    handlers[code] -> handler
    handler callable? not if
	"Handler for this option isn't callable value?!" simpleError
    fi
    handler #']unsupportedOptionHandler = if
	"No support for this option" simpleError
    fi

    lock withLockDo{
	[ | oobInput this that code op
	handler call{ [] $ $ $ $ $ -> }
    }
;

( =====================================================================	)
( - wantWontTelnetSocketOption             				)

:   wantWontTelnetSocketOption { $ $ -> }
    wantWont want
;
'wantWontTelnetSocketOption export

( =====================================================================	)
( - wantDontTelnetSocketOption             				)

:   wantDontTelnetSocketOption { $ $ -> }
    wantDont want
;
'wantDontTelnetSocketOption export

( =====================================================================	)
( - wantWillSocketOption	             				)

:   wantWillSocketOption { $ $ -> }
    wantWill want
;
'wantWontTelnetSocketOption export

( =====================================================================	)
( - wantDoSocketOption	             				)

:   wantDoSocketOption { $ $ -> }
    wantDo want
;
'wantDoTelnetSocketOption export


( =====================================================================	)
( - dontEcho			             				)

:   dontEcho { -> }
    @.jobSet.session.socket echo wantDont want
;
'dontEcho export


( =====================================================================	)
( - doEcho			             				)

:   doEcho { -> }
    @.jobSet.session.socket echo wantDo want
;
'doEcho export

( =====================================================================	)
( - willEcho			             				)

:   willEcho { -> }
    @.jobSet.session.socket echo wantWill want
;
'willEcho export


( =====================================================================	)
( - wontEcho			             				)

:   wontEcho { -> }
    @.jobSet.session.socket echo wantWont want
;
'wontEcho export


( =====================================================================	)
( - maybeWillEcho -- A willEcho safe to call from console		)

:   maybeWillEcho { -> }
    @.jobSet.session.socket -> socket
    socket.type :tcp = not if return fi
    willEcho
;
'maybeWillEcho export

( =====================================================================	)
( - maybeWontEcho -- A wontEcho safe to call from console		)

:   maybeWontEcho { -> }
    @.jobSet.session.socket -> socket
    socket.type :tcp = not if return fi
    wontEcho
;
'maybeWontEcho export



( =====================================================================	)
( - run				             				)

:   run { [] -> @ }

    ( Pop argument block passed to us by  )
    ( ]exec -- it is usually empty here   )
    ( and anyhow we don't use it:         )
    ]pop

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



    ( Configure self as telnet job for socket: )

    @.jobSet       -> jobset
    jobset.session -> session
    session.socket -> socket

    stateN 256 makeString -> this
    stateN 256 makeString -> that
    #']unsupportedOptionHandler 256 makeVector -> handlers
    #']supportedOptionHandler --> handlers[echo]

    makeMessageStream -> oobInput
    makeMessageStream -> oobOutput

    makeLock -> optionLock

    @          --> socket$s.outOfBandJob
    oobInput   --> socket$s.outOfBandInput
    oobOutput  --> socket$s.outOfBandOutput
    t          --> socket$s.telnetProtocol
    this       --> socket$s.thisTelnetState
    that       --> socket$s.thatTelnetState
    handlers   --> socket$s.telnetOptionHandler
    optionLock --> socket$s.telnetOptionLock
    ( For some reason, removing the $s's above hangs x-nanomud in test 25 )

    ( Infinite loop processing telnet commands: )
    do{
	( Read a telnet command: )
	t oobOutput
        readStreamPacket[ 
	-> who
	-> tag
	|length -> len

	optionLock withLockDo{
	    len case{

	    on: 2
		( The basic hardwired TELNET commands. )
		( These consist of IAC (0xFF) followed )
		( by a single opcode byte:             )
		|pop -> op
		]pop
		( Note that skt.t handles eraseLine   )
		( and eraseCharacter commands itself  )
		( when it can, and never passes them   )
		( to us, since we can't possibly do    )
		( anything useful with them:           )
		op case{
	   (    on: nop )
		on: dataMark           oobInput this that dataMarkFn
		on: telnetBreak        oobInput this that breakFn
		on: interruptProcess   oobInput this that interruptProcessFn
		on: abortOutput        oobInput this that abortOutputFn
		on: areYouThere       oobInput this that areYouThereFn
		on: goAhead            oobInput this that goAheadFn
		}

	    on: 3
		( The basic hardwired TELNET protocol   )
		( negotiation commands.  These consist  )
		( of IAC followed by one of WILL/WONT/  )
		( DO/DONT followed by a byte indicating )
		( the specific option to be negotiated: )
		|pop charInt -> code
		|pop -> op

		oobInput this that code op
		handlers[code] call{ [] $ $ $ $ $ -> }

	    else:
		( The only other commands should so far )
		( consist of IAC SB ... IAC SE brackets )
		( wrapped around some subOption:       )
		2 |dupNth charInt -> code

		oobInput this that code suboptionBegin
		handlers[code] call{ [] $ $ $ $ $ -> }
	    }
	}
    }

    } ( 6 )
    } ( 5 )
    } ( 4 )
    } ( 3 )
    } ( 2 )
    } ( 1 )
;

( =====================================================================	)
( - start			             				)

: start { -> ! }
    "telnet" forkJobset not if
        [ | #'run ]exec
    fi
;
'start export
#'start --> .u["root"]$s.telnetDaemon

( =====================================================================	)
( - maybeStartTelnetDaemon						)

:   maybeStartTelnetDaemon { -> }

    ( Find our socket: )
    @$s.jobSet$s.session$s.socket -> socket

    ( We attempt to only run the telnetDaemon )
    ( when there's likely to be telnet support )
    ( on the other end.  In particular, if     )
    ( socket$s.type is :tty we are on a direct )
    ( console connection:                      )
    socket$s.type :tcp = not if return fi
    
    ( Let's not clobber a telnetDaemon which  )
    ( is already running:                      )
    socket$s.telnetOptionLock if return fi

    ( Go for it: )
    me$s.telnetDaemon  -> daemon
    daemon callable? not if
        #'telnet:start -> daemon
    fi
    daemon callable? if
	daemon call{ -> }
    fi
;
'maybeStartTelnetDaemon export

( =====================================================================	)
( - stop			             				)

:   stop { -> }

    @$s.jobSet$s.session$s.socket -> socket

    socket$s.outOfBandJob -> j
    j job? if
	j abortJob
    fi

    nil --> socket$s.outOfBandJob
    nil --> socket$s.outOfBandInput
    nil --> socket$s.outOfBandOutput

    nil --> socket$s.telnetProtocol
    nil --> socket$s.thisTelnetState
    nil --> socket$s.thatTelnetState
    nil --> socket$s.telnetOptionHandlers
    nil --> socket$s.telnetOptionLock
;
'stop export

( - File variables							)


( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
