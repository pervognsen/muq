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

( - 010-C-event.muf -- Event system functionality.	                )
( - This file is formatted for outline-minor-mode in emacs19.           )
( -^C^O^A shows All of file.                                            )
(  ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)     )
(  ^C^O^T hides all Text. (Leaves all headings.)                        )
(  ^C^O^I shows Immediate children of node.                             )
(  ^C^O^S Shows all of a node.                                          )
(  ^C^O^D hiDes all of a node.                                          )
(  ^HFoutline-mode gives more details.                                  )
(  (Or do ^HI and read emacs:outline mode.)                             )

( ===================================================================== )
( - Dedication and Copyright.                                           )

(  -------------------------------------------------------------------  )
(                                                                       )
(               For Firiss:  Aefrit, a friend.                          )
(                                                                       )
(  -------------------------------------------------------------------  )

(  -------------------------------------------------------------------  )
( Author:       Jeff Prothero                                           )
( Created:      95Apr06                                                 )
( Modified:                                                             )
( Language:     MUF                                                     )
( Package:      N/A                                                     )
( Status:                                                               )
(                                                                       )
(  Copyright (c) 1996, by Jeff Prothero.                                )
(                                                                       )
(  This program is free software; you may use, distribute and/or modify )
(  it under the terms of the GNU Library General Public License as      )
(  published by the Free Software Foundation; either version 2, or at   )
(  your option  any later version FOR NONCOMMERCIAL PURPOSES.           )
(									)
(  COMMERCIAL operation allowable at $100/CPU/YEAR.			)
(  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.		)
(  Other commercial arrangements NEGOTIABLE.				)
(  Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.			)
(                                                                       )
(    This program is distributed in the hope that it will be useful,    )
(    but WITHOUT ANY WARRANTY; without even the implied warranty of     )
(    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      )
(    GNU Library General Public License for more details.               )
(                                                                       )
(    You should have received a copy of the GNU General Public License  )
(    along with this program: COPYING.LIB; if not, write to:            )
(       Free Software Foundation, Inc.                                  )
(       675 Mass Ave, Cambridge, MA 02139, USA.                         )
(                                                                       )
( JEFF PROTHERO DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,  )
( INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN   )
( NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR   )
( CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS   )
( OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,            )
( NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION  )
( WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.                         )
(                                                                       )
( Please send bug reports/fixes etc to bugs@@muq.org.			)
(  -------------------------------------------------------------------  )

( ===================================================================== )
( - Epigram.                                                            )

( The road to wisdom?                                                   )
(  well, it's plain                                                     )
(   and simple to express:                                              )
( To err                                                                )
(  and err                                                              )
(   and err again,                                                      )
( but less                                                              )
(  and less                                                             )
(   and less.                                                           )
(      -- Piet Hein                                                     )
  
( ===================================================================== )
( - Quote.                                                              )

( I was working for MIT in those days, and one thing I                  )
( did was to organize an MIT PDP-11 users' group and                    )
( encourage them to look into UNIX. The idea of a free,                 )
( non-vendor-supported operating system was new to                      )
( them. I invited Dennis Ritchie to come up and talk to                 )
( them.                                                                 )

( We went to lunch afterward, and I remarked to Dennis                  )
( that easily half the code I was writing in Multics was                )
( error recovery code. He said, "We left all that stuff                 )
( out. If there's an error, we have this routine called                 )
( panic, and when it is called, the machine crashes, and                )
( you holler down the hall, 'Hey, reboot it.'"                          )

( from http://www.best.com/~thvv/unix.html, a leaf of                   )
( http://www.best.com/~thvv/multics.html under                          )
( http://www.yahoo.com/Computers/History/                               )

( ===================================================================== )
( - WARNING                                                             )

( Muq cannot issue error messages successfully until this library       )
( has been installed.  This means that any errors introduced into       )
( this file tend to result in Muq just hanging mysteriously when        )
( trying to load it.  I suggest making modifications very carefully,    )
( in very small steps, if you need to do so.                            )


( - Public fns                                                          )

"muf" inPackage

( Symbol used in shell boilerplate: )
nil --> abrt
'abrt export

( ===================================================================== )
( - childOf2?                                                          )
( buggo, should be able to delete both childOf2? and childOf? now )
:   childOf2? { $ $ $ -> $ $ ! }
    -> n
    -> mom
    -> kid
    do{
        mom kid = if t n return fi
        n 0 = if nil n return fi
        n 1 - -> n
        kid.parents -> parents
        parents vector? if
            parents foreach i kid do{
                kid mom n childOf2? -> n if t n return fi
                n 0 = if nil n return fi
                n 1 - -> n
            }
            nil n return
        else
            parents not if nil n return fi
            parents -> kid
        fi
    }
;
'childOf2? export

( ===================================================================== )
( - childOf?                                                           )

: childOf? 512 childOf2? pop ;
'childOf? export

( ===================================================================== )
( - ]doSignal                                                          )

:   ]doSignal

    ( This function is the default value of   )
    ( @.doSignal, and hence gets called by    )
    ( the server when delivering a signal to  )
    ( the job.                                )

    :event |get -> event
    |getAllActiveHandlers[
        -> k
        -> hi
        -> lo
        for i from lo below hi do{
            i     dupBth -> eventN
            i k + dupBth -> handlerN
            .e.event event = if
                handlerN ]invokeHandler
            else
(               event eventN childOf? if ) ( old class system code )
                event eventN subclassOf? if
                    handlerN ]invokeHandler
            fi  fi
        }
    ]pop
    ]pop
;
']doSignal export
']doSignal --> .etc.jb0.doSignal

( ===================================================================== )
( - restartName                                                        )

: restartName { $ -> $ } -> restart

    ( A quick approximation to the CommonLisp function: )
    restart getRestart
    -> name
    -> fn
    -> tFn
    -> iFn
    -> rFn
    -> data
    -> id

    name
;
'restartName export

( ===================================================================== )
( - computeRestarts[                                                   )

: computeRestarts[ { $ -> [] } -> event

    ( Create block of restarts to return: )
    [ |

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

        ( Maybe add restart to our collection: )
        event if
            tFn        if
                event tFn call{ $ -> $ } if
                    id |push
                fi
            else
                id |push
            fi
        else
            id |push
        fi

        ( Next restart to try: )
        i 1 + -> i
    }
;
'computeRestarts[ export

( ===================================================================== )
( - findRestart                                                        )

: findRestart { $ $ -> $ } -> event -> restart

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
        id not if nil return fi

        ( If name matches id, return it: )
        id restart = if id return fi

        ( If names and maybe events match, return it: )
        name restart = if
            event not                 if id return fi
            tFn   not                 if id return fi
            event  tFn call{ $ -> $ } if id return fi
        fi

        ( Next restart to try: )
        i 1 + -> i
    }
;
'findRestart export

( ===================================================================== )
( - invokeRestart                                                      )

: invokeRestart { $ -> ! } -> restart

    restart symbol? if
        restart nil findRestart -> restart
    fi

    restart getRestart
    -> name
    -> fn
    -> tFn
    -> iFn
    -> rFn
    -> data
    -> id

    fn call{ -> }
;
'invokeRestart export

( ===================================================================== )
( - ]invokeRestart                                                     )

: ]invokeRestart { [] $ -> ! } -> restart

    restart symbol? if
        restart nil findRestart -> restart
    fi

    restart getRestart
    -> name
    -> fn
    -> tFn
    -> iFn
    -> rFn
    -> data
    -> id

    fn call{ [] -> }
;
']invokeRestart export




( ===================================================================== )
( - invokeRestartInteractively                                        )

: invokeRestartInteractively { $ -> ! } -> restart

    restart symbol? if
        restart nil findRestart -> restart
    fi

    restart getRestart
    -> name
    -> fn
    -> tFn
    -> iFn
    -> rFn
    -> data
    -> id

    iFn if
        iFn call{ -> [] }
        fn call{ [] -> }
    else
        fn call{ -> }
    fi
;
'invokeRestartInteractively export

( ===================================================================== )
( - ]invokeDebugger                                                    )

( : |dup[ { [] -> [] [] ! } ; ( Forward declaration )
: ]invokeDebugger { [] -> @ ! } 

    ( Invoke debugger_hook, if present: )
    @.debuggerHook -> dh
    dh compiledFunction? if
        ( We're supposed to bind rather than )
        ( set, but we'll cheat, since it is  )
        ( not really a symbol:               )
        after{
            nil --> @.debuggerHook
            |dup[ dh dh
            call{ [] $ -> }
        }alwaysDo{
            dh --> @.debugger_hook
        }
    fi

    ( Since debuggerHook returned, )
    ( invoke standard debugger:     )
    ]makeVector -> event
    @.debugger -> debugger
    debugger callable? if
        event debugger call{ $ -> @ }
    fi

    ( If no debugger, kill job: )
    "]invokeDebugger: Invalid @.debugger, killing job."
    @.errorOutput writeStream
    nil endJob
;
']invokeDebugger export

( ===================================================================== )
( - abort                                                               )

: abort { $ -> } -> event

    'abort event findRestart -> restart
    restart if
        restart invokeRestart
    fi
    [ :event .e.controlError | ]signal
;
'abort export

( ===================================================================== )
( - continue                                                            )

: continue { $ -> } -> event

    'continue event findRestart -> restart
    restart if restart invokeRestart fi
;
'continue export

( ===================================================================== )
( - muffleWarning                                                      )

: muffleWarning { $ -> } -> event

    'muffleWarning event findRestart -> restart
    restart if restart invokeRestart fi
    [ :event .e.controlError | ]signal
;
'muffleWarning export

( ===================================================================== )
( - storeValue                                                         )

: storeValue { $ $ -> } -> value -> event

    'storeValue event findRestart -> restart
    restart if [ value | restart ]invokeRestart fi
;
'storeValue export

( ===================================================================== )
( - useValue                                                           )

: useValue { $ $ -> } -> value -> event

    'useValue event findRestart -> restart
    restart if [ value | restart ]invokeRestart fi
;
'useValue export

( ===================================================================== )
( - reportEvent -- Standard err msg when dismissing an event		)

:   reportEvent { [] -> } |shift -> ostream
    :formatString |get -> formatString
    formatString if
        [ "Sorry: %s\n" formatString | ]print ostream writeStream
    else
        :event |get -> event
        [ "Sorry: %s\n" event.name | ]print ostream writeStream
    fi
    ]pop
;
'reportEvent export
'reportEvent --> .etc.jb0.reportEvent

( ===================================================================== )
( - ]cerror                                                             )

: ]cerror { [] -> ! } 

    ( Establish a 'cont tag that returns to caller: )
    withTag cont do{

        ( Establish a 'continue restart jumping to 'cont: )
        [   :function :: { -> ! } 'cont goto ;
            :name     'continue
            :reportFunction "Continue from ]cerror call."
        | ]withRestartDo{

            ( Issue the requested signal: )
            |dup[ ]signal

            ( Handlers didn't resolve event: )
            @.breakEnable if
                ]invokeDebugger
            else
                @.errorOutput |unshift @.reportEvent call{ [] -> }
                nil abort
            fi
        }
        cont
        ]pop
    }
;
']cerror export

( ===================================================================== )
( - ]error                                                              )

: ]error { [] -> @ ! } 

    ( Signal the given event: )
    |dup[ ]signal

    ( Handlers didn't resolve event: )
    @.breakEnable if
        ]invokeDebugger
    else
        @.errorOutput |unshift  @.reportEvent call{ [] -> }
        nil abort
    fi
;
']error export

( ===================================================================== )
( - ]warn                                                               )

: ]warn { [] -> } 

    ( Establish a 'muffle tag that returns to caller: )
    withTag muffle do{

        ( Establish a 'muffleWarning restart jumping to 'muffle: )
        [   :function :: { -> ! } 'muffle goto ;
            :name     'muffleWarning
            :reportFunction "Continue from ]warn call."
        | ]withRestartDo{

            ( Issue the requested signal: )
            |dup[ ]signal

            ( Write warning to errorOutput: )
            @.errorOutput |unshift  @.reportEvent call{ [] -> }
        }
        muffle
    }
;
']warn export

( ===================================================================== )
( - cerror                                                              )

: cerror { $ -> } -> formatString

    [   :event .e.simpleError
        :formatString formatString
    | ]cerror
;
'cerror export

( ===================================================================== )
( - error                                                               )

: error { $ -> @ } -> formatString

    [   :event .e.simpleError
        :formatString formatString
    | ]error
;
'error export

( ===================================================================== )
( - warn                                                                )

: warn { $ -> } -> formatString

    [   :event .e.simpleError
        :formatString formatString
    | ]warn
;
'warn export

( ===================================================================== )
( - ]doBreak                                                           )

: ]doBreak { [] -> @ }

    ( This function is the default value of   )
    ( @.doBreak, and hence gets called by  )
    ( the server when 'break' instruction is  )
    ( executed.                               )

    ( Save the event in a vector.     )
    ( We do this before setting the   )
    ( 'cont tag since we don't want   )
    ( the 'cont tag trying to restore )
    ( the event to the stack when     )
    ( invoked:                        )
    ]makeVector -> event

    ( Establish a 'cont tag that returns to caller: )
    withTag cont do{

        ( Establish a 'continue restart jumping to 'cont: )
        [   :function :: { -> ! } 'cont goto ;
            :name     'continue
            :reportFunction "Continue from 'break'."
        | ]withRestartDo{

            ( Invoke debugger.  We don't use     )
            ( "]invokeDebugger" here because it )
            ( checks @.debugger_hook, and     )
            ( CommonLisp specifies that 'break'  )
            ( shouldn't use @.debugger_hook.  )
            @.debugger -> debugger
            debugger compiledFunction? if
                event debugger call{ $ -> @ }
            fi

            ( If no debugger, kill job: )
            "break: Invalid @.debugger, killing job." ,
            nil endJob
        }
        cont
    }
;
']doBreak export
']doBreak --> .u["root"].doBreak
']doBreak --> .etc.jb0.doBreak

( ===================================================================== )
( - doError                                                            )

: doError { $ $ -> @ } -> formatString -> event

    ( This function is the default value of   )
    ( @.doError, and hence gets called by  )
    ( the server when an error is detected,   )
    ( as the first part of the errorHandling )
    ( process.                                )

    ( Construct an appropriate event: )
    [   :event        event
        :formatString formatString
    | ]error
;
'doError export
'doError --> .etc.jb0.doError

( ===================================================================== )

( - File variables                                                      )


( Local variables:                                                      )
( mode: outline-minor                                                   )
( outline-regexp: "( -+"                                                )
( End:                                                                  )

@end example
