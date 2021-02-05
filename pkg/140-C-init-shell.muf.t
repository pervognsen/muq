@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Init Shell, Init Shell Overview, , Top
@chapter Init Shell

@menu
* Init Shell Overview::
* Init Shell Source::
* Init Shell Wrapup::
@end menu

@c
@node Init Shell Overview, Init Shell Source, Init Shell, Init Shell
@section Init Shell Overview

This chapter documents the in-db (@sc{muf}) implementation of the
@sc{init} shell, and includes all the source.  The init shell
initializes the db when Muq is booted in daemon mode (that is, with
the @code{-d} commandline switch), principally by starting up the
daemons specified in @code{.etc.rc2}.

@c
@node Init Shell Source, Init Shell Wrapup, Init Shell Overview, Init Shell
@section Init Shell Source

@example  @c

( - 140-C-init-shell.muf -- Daemon mode initialization shell.		)
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
( Created:      97Jul04 (moved from mufShell file)			)
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

(    How to write software that really matters:				)
(									)
(	Use computers for something that really matters.		)
(	Press on until the software breaks: Nothing available works.	)
(	(Trust me, it -will- happen.)					)
(	Write the software you need to continue.			)
(									)
(    Everything should be so simple. :)					)



( =====================================================================	)
( - Select MUF Package:							)

"muf" inPackage

( =====================================================================	)
( - initShell -- Start-of-world shell for daemon mode			)

:   initShell { -> ? }

    ( This is what the server executes	  )
    ( to start up the server in daemon    )
    ( mode ( -d commandline switch).	  )

    (      -- BEGIN BOILERPLATE --        )

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
	:reportFunction "Return to main initShell prompt."
    | ]withRestartDo{               ( 3 )

    ( Establish a handler letting users   )
    ( abort a job with a signal           )
    ( -- via 'abortJob' say:             )
    [ .e.abort :: { [] -> [] ! } 'abort invokeRestart ;
    | ]withHandlerDo{               ( 4 )

    withTag abrt do{       ( 8 ) ( Trap compile errs etc    )
    abrt                          ( Continuation from errors )
    (       -- END BOILERPLATE --         )


    ( Establish handler to report errors: )
    [ .e.error ( simpleError or serverError, presumably )
      ']reportCompileError
    | ]withHandlersDo{              ( 5 )


    ( Right now, all we do is execute .etc.rc2. )
    ( We could become a cron server after that, )
    ( maybe?  Right now we just die:            )
    .etc.rc2 callable? if
	.etc.rc2 call{ -> }
    fi

    nil endJob

    } ( 8 )
    } ( 5 )
    } ( 4 )
    } ( 3 )
    } ( 2 )
    } ( 1 )
;
'initShell export

( =====================================================================	)
( - rc2 -- Function to start up multiuser daemon mode			)
:   rc2 { -> }

    ( Sanity checks: )
    @.actingUser root? not if
        "Must be root to use 'rc2'." simpleError
    fi

    ( Make list of all keys in .etc.rc2D: )
    .etc.rc2D keys[

        ( Drop all non-keyword keys from block: )
	0 -> i
	do{ |length i = until
	    i |dupNth keyword? if
		++ i
	    else
		i |popNth pop
	    fi
	}

	( Sort keywords alphabetically by name: )
	|keysKeysvals
	|forPairs k v do{ k.name -> k }
	|keysvalsSort
	|vals

	( Execute all corresponding fns in order: )
	|for k do{
	    .etc.rc2D[k] -> fn
	    fn callable? if
		fn call{ -> }
	    fi
	}
    ]pop
;
'rc2 export
'rc2 --> .etc.rc2



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
questions or suggestions, feel free to email cynbe@@sl.tcp.com.
