@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Muf Shell, Muf Shell Overview, , Top
@chapter Muf Shell

@menu
* Muf Shell Overview::
* Muf Shell Source::
* Muf Shell Wrapup::
@end menu

@c
@node Muf Shell Overview, Muf Shell Source, Muf Shell, Muf Shell
@section Muf Shell Overview

This chapter documents the in-db (@sc{muf}) implementation of the
@sc{muf} shell, and includes all the source.  You most definitely
do not need to read or understand this chapter in order to use
the @sc{muf}, shell, but you may find it interesting if you
are curious about the internals of the @sc{muf} shell, or are
interested in writing a Muq shell of your own.

@c
@node Muf Shell Source, Muf Shell Wrapup, Muf Shell Overview, Muf Shell
@section Muf Shell Source

@example  @c

( - 140-C-muf-shell.muf -- Shell using "Multi-User Forth".		)
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

(  -------------------------------------------------------------------	)
( Author:       Jeff Prothero						)
( Created:      97Jul04 (movedd from mufShell)			)
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
(  -------------------------------------------------------------------	)

( =====================================================================	)
( - Thought								)

( 	Mysticism is the shadow of ignorance:				)
(	Understanding changes awe to appreciation.			)

( =====================================================================	)
( - Select MUF Package:							)

"muf" inPackage

( =====================================================================	)
( - ]shell -- Simple muf shell.						)

: ]shell { [] -> ? }

    ( Process argblock: )

    ( Get stream to read from: )
    |pop -> mss
    mss isAMessageStream
    ]pop

    ( Allocate a compiler context.  Normally we would do )
    ( [ :ephemeral t | 'compile:]makeContext -> ctx      )
    ( but since ctx is ephemeral, that would result in   )
    ( it being allocated in the makeContext stackframe   )
    ( and popped off the loop stack when ]makeContext    )
    ( returned -- before we had a chance to use it.  So  )
    ( instead we directly call the ]makeStructure prim   )
    ( which results in it being allocated in ]shell's    )
    ( stackframe:                                        )
    [   :ephemeral t
        :mss       mss
        :package   .lib["muf"]
        :outermost t
    | 'compile:context ]makeStructure -> ctx

    ( Allocate a function object to compile into: )
    makeFunction -> fun


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
    [   :function :: { -> ! }  'abrt goto ;
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
    (       -- SUSPEND BOILERPLATE --          )


    ( Establish a handler that will print )
    ( active jobs on .etc.printJobs:     )
    [ .e.printJobs :: { [] -> [] ! } printJobs ;
    | ]withHandlerDo{               ( 7 )
    
    ( Configure socket to generate an     )
    ( .e.printJobs signal on ^T:       )
    @$s.jobSet$s.session$s.socket -> sock
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

    ( Note date of last garbage collect and backup: )
    .muq.dateOfLastGarbageCollect -> lastGc
    .muq.dateOfLastBackup         -> lastBackup


    "MUF (Multi-User Forth) shell starting up\n" ,
    "(Do   muc:shell   to start up Multi-User C shell.)\n" ,

    (       -- CONTINUE BOILERPLATE --         )
    showLoginHints

    "muf:]shell starting up.\n" log,
    withTags abrt exitShell do{ ( 9 ) ( Trap compile errs etc    )
    abrt                          ( Continuation from errors )
    (       -- END BOILERPLATE --         )

    ( Central readEvalPrint loop: )
    do{
	( Inform user if a gc or backup has been done: )
	.muq.dateOfLastGarbageCollect -> d
	d lastGc != if
	    [ "%g-sec garbage collect %g secs ago freed %d bytes, %d blocks.\n"
	        .muq$s.millisecsForLastGarbageCollect 0.001 *
	        .sys$s.millisecsSince1970 d -         0.001 *
	        .muq$s.bytesRecoveredInLastGarbageCollect
	        .muq$s.blocksRecoveredInLastGarbageCollect
	    |   ]print ,
	    d -> lastGc
	fi
	.muq.dateOfLastBackup -> d
	d lastBackup != if
	    [   "Backup done %g secs ago, took %g secs.\n"
	        .sys$s.millisecsSince1970 d -  0.001 *
	        .muq$s.millisecsForLastBackup  0.001 *
	    |   ]print ,
	    d -> lastBackup
	fi

	( Save compile context where )
        ( user code &tc can find it: )
	ctx --> @$s.compiler

	( Reset assembler for new function: )
        [ ctx | compile:resetContext ]pop

        ( Issue prompt: )
	@$s.package$s.name , ": " , ( prompt                   )
	print1DataStack ,           ( Print out data stack     )
	"\n" ,                      ( New line for user input  )


	( Loop accumulating tokens until we reach )
	( an \n with no control structures open:  )
	nil --> ctx.ateNewline
	do{
	    compile:modeGet ctx compilePath
	    ctx.syntax length 0 =   ctx.ateNewline   and until
	}

	ctx.asm$s.bytecodes 0 != if

	    ( Complete assembly: )
	    t 0 fun ctx.asm finishAssembly -> cfn

	    ( Plug source and executable into fn: )
	    ""   --> fun$s.source
	    cfn  --> fun$s.executable

	    ( Execute compiled function: )
	    cfn call{ -> }
	fi
    }

    exitShell                    ( Exit from shell          )
    "muf:]shell exiting.\n" log,
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



( =====================================================================	)
( - shell -- Easy invocation of vanilla muf shell.			)

: shell { -> ? }
    [ @$s.standardInput | ]shell
;
'shell export


( =====================================================================	)
( - exitShell -- Function to exit shell.				)

: exitShell { -> @ ! }
    'exitShell goto
;
'exitShell export


( =====================================================================	)
( - Install muf:shell as default shell muf:mufShell			)

'mufShell export
#']shell --> #'mufShell


( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

@c
@node Muf Compiler Wrapup, Function Index, Muf Compiler Source, Muf Compiler
@section Muf Compiler Wrapup

This completes the in-db @sc{muf}-compiler chapter.  If you have
questions or suggestions, feel free to email cynbe@@muq.org.
