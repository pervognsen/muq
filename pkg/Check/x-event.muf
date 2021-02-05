( --------------------------------------------------------------------- )
(			x-event.muf				    CrT )
( Exercise event system stuff.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      95Apr12							)
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
(  Contact cynbe@eskimo.com for a COMMERCIAL LICENSE.			)
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
( NO EVENT SHALL Jeff Prothero BE LIABLE FOR ANY SPECIAL, INDIRECT OR	)
( CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	)
( OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		)
( NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	)
( WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.				)
( 									)
( Please send bug reports/fixes etc to bugs@@muq.org.			)
( ---------------------------------------------------------------------	)
( --------------------------------------------------------------------- )
(                              history                              CrT )
(                                                                       )
( 95Apr12 jsp	Created.						)
( --------------------------------------------------------------------- )

"Event system tests\n" log,
"\nEvent system tests:" ,


( Tests 1-6: Check fetching top restart works: )
::  ; --> fn
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        0 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    name 'f =
; shouldBeTrue
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        0 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    f fn =
; shouldBeTrue
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        0 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    tFn nil =
; shouldBeTrue
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        0 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    iFn nil =
; shouldBeTrue
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        0 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    rFn nil =
; shouldBeTrue
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        0 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    id integer?
; shouldBeTrue
( Tests 7-12: Check fetching missing restart works: )
( Check fetching missing restart works: )
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        4 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    name nil =
; shouldBeTrue
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        4 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    f nil =
; shouldBeTrue
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        4 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    tFn nil =
; shouldBeTrue
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        4 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    iFn nil =
; shouldBeTrue
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        4 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    rFn nil =
; shouldBeTrue
::  [
        :function fn
        :name     'f
    | ]withRestartDo{
        4 getNthRestart
        -> name
        -> f
        -> tFn
        -> iFn
        -> rFn
        -> data
        -> id
    }
    id nil =
; shouldBeTrue
( Tests 13-18: Check fetching second restart works: )
:: 2 ; --> fn2
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    1 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    name 'f2 =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    1 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    f fn2 =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    1 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    tFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    1 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    iFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    1 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    rFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    1 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    id integer?
; shouldBeTrue

( Tests 19-24: Check fetching 1st of two restarts works: )
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    0 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    name 'f =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    0 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    f fn =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    0 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    tFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    0 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    iFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    0 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    rFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    0 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    id integer?
; shouldBeTrue

( Tests 25-30: Check 'find'ing 1st of two restarts by name works: )
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    0 getNthRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    name 'f =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    'f nil findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    f fn =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    'f nil findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    tFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    'f nil findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    iFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    'f nil findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    rFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    'f nil findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    id integer?
; shouldBeTrue

( Tests 31-36: Check 'find'ing 2nd of two restarts by name works: )
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    'f2 nil findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    name 'f2 =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    'f2 nil findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    f fn2 =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    'f2 nil findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    tFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    'f2 nil findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    iFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    'f2 nil findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    rFn nil =
; shouldBeTrue
::  [
        :function fn2
        :name     'f2
    | ]withRestartDo{
        [
	    :function fn
	    :name     'f
	| ]withRestartDo{
	    'f2 nil findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    id integer?
; shouldBeTrue

( Tests 37-42: Check 'find'ing 1st of two   )
( identically named restarts by tFn works: )
: dbz .e.divisionByZero = ;
: fpo .e.floatingPointOverflow = ;

::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.floatingPointOverflow findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    name 'f =
; shouldBeTrue
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.floatingPointOverflow findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    f fn =
; shouldBeTrue
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.floatingPointOverflow findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    tFn #'fpo =
; shouldBeTrue
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.floatingPointOverflow findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    iFn nil =
; shouldBeTrue
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.floatingPointOverflow findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    rFn nil =
; shouldBeTrue
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.floatingPointOverflow findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    id integer?
; shouldBeTrue

( Tests 43-48: Check 'find'ing 2nd of two   )
( identically named restarts by tFn works: )
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.divisionByZero findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    name 'f =
; shouldBeTrue
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.divisionByZero findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    f fn2 =
; shouldBeTrue
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.divisionByZero findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    tFn #'dbz =
; shouldBeTrue
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.divisionByZero findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    iFn nil =
; shouldBeTrue
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.divisionByZero findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    rFn nil =
; shouldBeTrue
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    'f .e.divisionByZero findRestart getRestart
	    -> name
	    -> f
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id
    }   }
    id integer?
; shouldBeTrue

( Tests 49: Compute-restarts finding all restarts: )
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    nil computeRestarts[ |length -> len ]pop
    }   }
    len 5 =
; shouldBeTrue

( Tests 50-51: Compute-restarts finding  )
( all restarts matching given event: )
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    .e.divisionByZero computeRestarts[ |length -> len ]pop
    }   }
    len 4 =
; shouldBeTrue
::  [
        :function fn2
	:testFunction #'dbz
        :name     'f
    | ]withRestartDo{
        [
	    :function fn
	    :testFunction #'fpo
	    :name     'f
	| ]withRestartDo{
	    .e.floatingPointOverflow computeRestarts[ |length -> len ]pop
    }   }
    len 4 =
; shouldBeTrue

( Tests 52-55: Finding all handlers: )
0 --> _handlersFound
t --> _allEventsOk
t --> _allHandlersOk
::
    [ .e.warning :: ; | ]withHandlerDo{
	[ 'a' 'b' |
	    |getAllActiveHandlers[ -> k -> hi -> lo
		k --> _handlersFound
		for i from lo below hi do{
		    i     dupBth -> event
		    i k + dupBth -> handler
		    ++ _handlersFound
		    handler integer? not if
			nil --> _allHandlersOk
		    fi
( buggo -- what's the appropriate new test here? )
(		    event event? not if          )
(			nil --> _allEventsOk     )
(		    fi )
		}
	    ]pop
        ]pop
    }
; shouldWork
:: _handlersFound 0 > ; shouldBeTrue
:: _allEventsOk       ; shouldBeTrue
:: _allHandlersOk     ; shouldBeTrue

( Tests 56-60: childOf?: )
:: .e.warning .e.warning   subclassOf? ; shouldBeTrue
:: .e.warning .e.event     subclassOf? ; shouldBeTrue
:: .e.event .e.warning     subclassOf? ; shouldBeFalse
:: .e.divisionByZero .e.event subclassOf? ; shouldBeTrue
:: .e.divisionByZero .e.warning subclassOf? ; shouldBeFalse



( Tests 61-69: Invoking a local handler: )

( Make some events nobody else will catch: )
defclass: EventRed ;  :: 'EventRed.type --> _eventRed ; shouldWork
defclass: EventBlu ;  :: 'EventBlu.type --> _eventBlu ; shouldWork
( :: makeEvent --> _eventRed ; shouldWork )
( :: makeEvent --> _eventBlu ; shouldWork )

( Try setting and invoking a handler on it: )
nil --> _handlerFired
::  withTag hee do{
      [   _eventRed
          :: { [] -> [] ! }  ]pop  t --> _handlerFired  ]pop 'hee goto ;
      | ]withHandlerDo{
	  [ :event _eventRed | ]signal
      }
      hee
    }
    _handlerFired
; shouldBeTrue

( Same, with two handlers set: )
nil --> _handlerFired
::  withTag hee do{
      [   _eventRed :: { [] -> [] ! }   t --> _handlerFired ]pop 'hee goto ;
	  _eventBlu :: { [] -> [] ! } nil --> _handlerFired ]pop 'hee goto ;
      | ]withHandlerDo{
	  [ :event _eventRed | ]signal
      }
      hee
    }
    _handlerFired
; shouldBeTrue
t --> _handlerFired
::  withTag hee do{
      [   _eventRed :: { [] -> [] ! }   t --> _handlerFired ]pop 'hee goto ;
	  _eventBlu :: { [] -> [] ! } nil --> _handlerFired ]pop 'hee goto ;
      | ]withHandlerDo{
	  [ :event _eventBlu | ]signal
      }
      hee
    }
    _handlerFired
; shouldBeFalse

( Check that handler is inactive while running: )
0 --> _handlerCount
::  withTag hee do{
      [   _eventRed
	  ::  { [] -> [] ! } ]pop 'hee goto ;
      | ]withHandlerDo{
	[   _eventRed
	    ::  { [] -> [] ! }
		++ _handlerCount
		[ :event _eventRed | ]signal
	    ;
	| ]withHandlerDo{
	  [ :event _eventRed | ]signal
        }
      }
      hee
    }
    1 _handlerCount =
; shouldBeTrue

( Check that related handlers are )
( inactive while ours is running: )
nil --> _handlerFired
::  withTag hee do{
      [   _eventRed
	  ::  { [] -> [] ! } 'hee goto ;
	  _eventBlu
	  ::  { [] -> [] ! } 'hee goto ;
      | ]withHandlerDo{
	[   _eventRed
	    ::  { [] -> [] ! }
		[ :event _eventBlu | ]signal
	    ;

	    _eventBlu
	    ::  { [] -> [] ! }
		t --> _handlerFired
	    ;
	| ]withHandlerDo{
	  [ :event _eventRed | ]signal
	}
      }
      hee
    }
    _handlerFired
; shouldBeFalse

( Check that unrelated handlers are )
( active while ours is running:     )
nil --> _handlerFired
::  withTag hee do{
	[   _eventRed
	    ::  { [] -> [] ! }
		[ :event _eventBlu | ]signal
	    ;
	| ]withHandlerDo{
	    [   _eventBlu
		::  { [] -> [] ! }
		    t --> _handlerFired
		    'hee goto
		;
	    | ]withHandlerDo{
		[ :event _eventRed | ]signal
	}   }
        hee
    }
    _handlerFired
; shouldBeTrue
nil --> _handlerFired
::  withTag hee do{
	[   _eventBlu
	    ::  { [] -> [] ! }
		t --> _handlerFired
	        'hee goto
	    ;
	| ]withHandlerDo{
	    [   _eventRed
		::  { [] -> [] ! }
		    [ :event _eventBlu | ]signal
		;
	    | ]withHandlerDo{
		[ :event _eventRed | ]signal
	}   }
        hee
    }
    _handlerFired
; shouldBeTrue


( Test 70: Put it all together:  )
( Signal a handler that invokes  )
( a restart that jumps to a tag: )
nil --> _looksGood
::  withTag my-tag do{
        [   :function :: { -> ! } 'my-tag goto ;
	    :name     'my-restart
	| ]withRestartDo{
	    [   _eventRed
		::  { [] -> [] ! }
		    'my-restart invokeRestart
		;
	    | ]withHandlerDo{
		[ :event _eventRed | ]signal
	}   }

	t if
	    nil --> _looksGood
	else
	my-tag
	    t   --> _looksGood
	fi
    }
    _looksGood
; shouldBeTrue

( Test 71: Same,but with restart )
( taking a block argument:       )
nil --> _looksGood
::  withTag my-tag do{
        [   :function :: { [] -> ! } ]pop 'my-tag goto ;
	    :name     'my-restart
	| ]withRestartDo{
	    [   _eventRed
		::  { [] -> [] ! }
		    [ 0 1 | 'my-restart ]invokeRestart
		;
	    | ]withHandlerDo{
		[ :event _eventRed | ]signal
	}   }

	t if
	    nil --> _looksGood
	else
	my-tag
	    t   --> _looksGood
	fi
    }
    _looksGood
; shouldBeTrue

( Test 72-76: ]invokeDebugger )
@.debuggerHook --> _oldDebuggerHook
@.debugger      --> _oldDebugger
t   --> _debuggerHookValue
nil --> _debuggerHookCalled
nil --> _debuggerCalled
t   --> _bypassedEnd
::  pop ]pop ( Called with ourself atop event )
    t --> _debuggerHookCalled
    @.debuggerHook --> _debuggerHookValue
; --> @.debuggerHook
::  withTag my-tag do{
        :: pop t --> _debuggerCalled 'my-tag goto ; --> @.debugger
        [ | ]invokeDebugger
        nil --> _bypassedEnd
    my-tag
    }
; shouldWork
_oldDebuggerHook --> @.debuggerHook
_oldDebugger      --> @.debugger 
:: _debuggerHookValue nil = ; shouldBeTrue
:: _debuggerHookCalled      ; shouldBeTrue
:: _debuggerCalled           ; shouldBeTrue
:: _bypassedEnd              ; shouldBeTrue

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
