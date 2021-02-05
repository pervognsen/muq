( --------------------------------------------------------------------- )
(			x-lambda.muf				    CrT )
( Exercise lambdaList support.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      96Mar09							)
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
( 96Mar09 jsp	Created.						)
( --------------------------------------------------------------------- )

"Lambda-list tests\n" log,
"\nLambda-list tests:" ,

( Test 1: )
::  0  0  0  0  makeLambdaList --> _l ; shouldWork

( Tests 2-5: )
:: -1  0  0  0  makeLambdaList pop ; shouldFail
::  0 -1  0  0  makeLambdaList pop ; shouldFail
::  0  0 -1  0  makeLambdaList pop ; shouldFail
::  0  0  0 -1  makeLambdaList pop ; shouldFail

( Tests 6-9: )
:: nil 0  0  0  makeLambdaList pop ; shouldFail
::  0 nil 0  0  makeLambdaList pop ; shouldFail
::  0  0 nil 0  makeLambdaList pop ; shouldFail
::  0  0  0 nil makeLambdaList pop ; shouldFail

( Tests 10-12: )
::  1  3  2  6  makeLambdaList --> _l ; shouldWork
::  _l isALambdaList ; shouldWork
::  _l lambdaList? ; shouldBeTrue

( Tests 13-77: )
:: _l :name -1 "0" setLambdaSlotProperty ; shouldFail
:: _l :name  0 "0" setLambdaSlotProperty ; shouldWork
:: _l :name  1 "1" setLambdaSlotProperty ; shouldWork
:: _l :name  2 "2" setLambdaSlotProperty ; shouldWork
:: _l :name  3 "3" setLambdaSlotProperty ; shouldWork
:: _l :name  4 :e  setLambdaSlotProperty ; shouldWork
:: _l :name  5 :f  setLambdaSlotProperty ; shouldWork
:: _l :name  6 "6" setLambdaSlotProperty ; shouldFail

( Some functions to use as initforms: )
: if-70 70 ;
: if-71 71 ;
: if-72 72 ;
: if-73 73 ;
: if-74 74 ;
: if-75 75 ;

:: _l :initval -1 11  setLambdaSlotProperty ; shouldFail
:: _l :initval  0 10  setLambdaSlotProperty ; shouldWork
:: _l :initval  1 11  setLambdaSlotProperty ; shouldWork
:: _l :initval  2 12  setLambdaSlotProperty ; shouldWork
:: _l :initval  3 13  setLambdaSlotProperty ; shouldWork
:: _l :initval  4 14  setLambdaSlotProperty ; shouldWork
:: _l :initval  5 15  setLambdaSlotProperty ; shouldWork
:: _l :initval  6 16  setLambdaSlotProperty ; shouldFail

:: _l :initform -1 #'if-71 setLambdaSlotProperty ; shouldFail
:: _l :initform  0 #'if-70 setLambdaSlotProperty ; shouldWork
:: _l :initform  1 #'if-71 setLambdaSlotProperty ; shouldWork
:: _l :initform  2 #'if-72 setLambdaSlotProperty ; shouldWork
:: _l :initform  3 #'if-73 setLambdaSlotProperty ; shouldWork
:: _l :initform  4 #'if-74 setLambdaSlotProperty ; shouldWork
:: _l :initform  5 #'if-75 setLambdaSlotProperty ; shouldWork
:: _l :initform  6 #'if-75 setLambdaSlotProperty ; shouldFail



:: _l :name -1 getLambdaSlotProperty       ; shouldFail
:: _l :name  0 getLambdaSlotProperty "0" = ; shouldBeTrue
:: _l :name  1 getLambdaSlotProperty "1" = ; shouldBeTrue
:: _l :name  2 getLambdaSlotProperty "2" = ; shouldBeTrue
:: _l :name  3 getLambdaSlotProperty "3" = ; shouldBeTrue
:: _l :name  4 getLambdaSlotProperty :e  = ; shouldBeTrue
:: _l :name  5 getLambdaSlotProperty :f  = ; shouldBeTrue
:: _l :name  6 getLambdaSlotProperty       ; shouldFail

:: _l :initval -1  getLambdaSlotProperty      ; shouldFail
:: _l :initval  0  getLambdaSlotProperty 10 = ; shouldBeTrue
:: _l :initval  1  getLambdaSlotProperty 11 = ; shouldBeTrue
:: _l :initval  2  getLambdaSlotProperty 12 = ; shouldBeTrue
:: _l :initval  3  getLambdaSlotProperty 13 = ; shouldBeTrue
:: _l :initval  4  getLambdaSlotProperty 14 = ; shouldBeTrue
:: _l :initval  5  getLambdaSlotProperty 15 = ; shouldBeTrue
:: _l :initval  6  getLambdaSlotProperty      ; shouldFail

:: _l :initform -1  getLambdaSlotProperty           ; shouldFail
:: _l :initform  0  getLambdaSlotProperty #'if-70 = ; shouldBeTrue
:: _l :initform  1  getLambdaSlotProperty #'if-71 = ; shouldBeTrue
:: _l :initform  2  getLambdaSlotProperty #'if-72 = ; shouldBeTrue
:: _l :initform  3  getLambdaSlotProperty #'if-73 = ; shouldBeTrue
:: _l :initform  4  getLambdaSlotProperty #'if-74 = ; shouldBeTrue
:: _l :initform  5  getLambdaSlotProperty #'if-75 = ; shouldBeTrue
:: _l :initform  6  getLambdaSlotProperty           ; shouldFail

:: _l.requiredArgs 1 = ; shouldBeTrue
:: _l.optionalArgs 3 = ; shouldBeTrue
:: _l.keywordArgs  2 = ; shouldBeTrue
:: _l.totalArgs    6 = ; shouldBeTrue
:: _l.allowOtherKeywords ; shouldBeTrue



( Clear the initforms so we can test initvals: )
:: _l :initform  0 nil setLambdaSlotProperty ; shouldWork
:: _l :initform  1 nil setLambdaSlotProperty ; shouldWork
:: _l :initform  2 nil setLambdaSlotProperty ; shouldWork
:: _l :initform  3 nil setLambdaSlotProperty ; shouldWork
:: _l :initform  4 nil setLambdaSlotProperty ; shouldWork
:: _l :initform  5 nil setLambdaSlotProperty ; shouldWork

( Verify that they cleared: )
:: _l :initform  0 getLambdaSlotProperty nil = ; shouldBeTrue
:: _l :initform  1 getLambdaSlotProperty nil = ; shouldBeTrue
:: _l :initform  2 getLambdaSlotProperty nil = ; shouldBeTrue
:: _l :initform  3 getLambdaSlotProperty nil = ; shouldBeTrue
:: _l :initform  4 getLambdaSlotProperty nil = ; shouldBeTrue
:: _l :initform  5 getLambdaSlotProperty nil = ; shouldBeTrue



( A convenience function to compare two blocks of length 6: )
: ]]6= { [] [] -> $ }
  |length 6 = not if "short!" error fi
  |pop -> f
  |pop -> e
  |pop -> d
  |pop -> c
  |pop -> b
  |pop -> a
  ]pop
  |length 6 = not if "short!" error fi
  |pop f =       -> r
  |pop e = r and -> r
  |pop d = r and -> r
  |pop c = r and -> r
  |pop b = r and -> r
  |pop a = r and -> r
  ]pop
  r
;

( Test it: )
:: [ 'a 'b 'c 'd 'e 'f | [ 'a 'b 'c 'd 'e 'f | ]]6= ; shouldBeTrue



( Tests 78-86: |applyLambdaList: )
:: [ | _l |applyLambdaList
   [ 61 11 12 13 14 15 |
   ]]6=
; shouldFail

:: [ 61 | _l |applyLambdaList
   [ 61 11 12 13 14 15 |
   ]]6=
; shouldBeTrue

:: [ 61 62 | _l |applyLambdaList
   [ 61 62 12 13 14 15 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 | _l |applyLambdaList
   [ 61 62 63 13 14 15 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 | _l |applyLambdaList
   [ 61 62 63 64 14 15 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :e 65 | _l |applyLambdaList
   [ 61 62 63 64 65 15 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :f 66 | _l |applyLambdaList
   [ 61 62 63 64 14 66 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :e 65 :f 66 | _l |applyLambdaList
   [ 61 62 63 64 65 66 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :f 66 :e 65 | _l |applyLambdaList
   [ 61 62 63 64 65 66 |
   ]]6=
; shouldBeTrue




( Tests 87-101: |applyLambdaListSlowly: )
:: [ | _l |applyLambdaListSlowly
   [ 61 11 12 13 14 15 |
   ]]6=
; shouldFail

:: [ 61 | _l |applyLambdaListSlowly
   [ 61 11 12 13 14 15 |
   ]]6=
; shouldBeTrue

:: [ 61 62 | _l |applyLambdaListSlowly
   [ 61 62 12 13 14 15 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 | _l |applyLambdaListSlowly
   [ 61 62 63 13 14 15 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 | _l |applyLambdaListSlowly
   [ 61 62 63 64 14 15 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :e 65 | _l |applyLambdaListSlowly
   [ 61 62 63 64 65 15 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :f 66 | _l |applyLambdaListSlowly
   [ 61 62 63 64 14 66 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :e 65 :f 66 | _l |applyLambdaListSlowly
   [ 61 62 63 64 65 66 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :f 66 :e 65 | _l |applyLambdaListSlowly
   [ 61 62 63 64 65 66 |
   ]]6=
; shouldBeTrue


( Restore the initforms: )
:: _l :initform  0 #'if-70 setLambdaSlotProperty ; shouldWork
:: _l :initform  1 #'if-71 setLambdaSlotProperty ; shouldWork
:: _l :initform  2 #'if-72 setLambdaSlotProperty ; shouldWork
:: _l :initform  3 #'if-73 setLambdaSlotProperty ; shouldWork
:: _l :initform  4 #'if-74 setLambdaSlotProperty ; shouldWork
:: _l :initform  5 #'if-75 setLambdaSlotProperty ; shouldWork


( Tests 102-110: direct |applyLambdaListSlowly )
( implementation of the initforms:      )
:: [ | _l |applyLambdaListSlowly
   [ 61 11 12 13 14 15 |
   ]]6=
; shouldFail

:: [ 61 | _l |applyLambdaListSlowly
   [ 61 71 72 73 74 75 |
   ]]6=
; shouldBeTrue

:: [ 61 62 | _l |applyLambdaListSlowly
   [ 61 62 72 73 74 75 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 | _l |applyLambdaListSlowly
   [ 61 62 63 73 74 75 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 | _l |applyLambdaListSlowly
   [ 61 62 63 64 74 75 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :e 65 | _l |applyLambdaListSlowly
   [ 61 62 63 64 65 75 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :f 66 | _l |applyLambdaListSlowly
   [ 61 62 63 64 74 66 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :e 65 :f 66 | _l |applyLambdaListSlowly
   [ 61 62 63 64 65 66 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :f 66 :e 65 | _l |applyLambdaListSlowly
   [ 61 62 63 64 65 66 |
   ]]6=
; shouldBeTrue


( Tests 111-119: indirect |applyLambdaList )
( implementation of the initforms: )
:: [ | _l |applyLambdaList
   [ 61 11 12 13 14 15 |
   ]]6=
; shouldFail

:: [ 61 | _l |applyLambdaList
   [ 61 71 72 73 74 75 |
   ]]6=
; shouldBeTrue

:: [ 61 62 | _l |applyLambdaList
   [ 61 62 72 73 74 75 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 | _l |applyLambdaList
   [ 61 62 63 73 74 75 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 | _l |applyLambdaList
   [ 61 62 63 64 74 75 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :e 65 | _l |applyLambdaList
   [ 61 62 63 64 65 75 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :f 66 | _l |applyLambdaList
   [ 61 62 63 64 74 66 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :e 65 :f 66 | _l |applyLambdaList
   [ 61 62 63 64 65 66 |
   ]]6=
; shouldBeTrue

:: [ 61 62 63 64 :f 66 :e 65 | _l |applyLambdaList
   [ 61 62 63 64 65 66 |
   ]]6=
; shouldBeTrue



( Tests 120-124: )
( ]setLocalVars: )
:: 0 -> a 1 -> b [ 'a 'b 'c | ]setLocalVars ; shouldFail
:: 0 -> a 1 -> b [ 'a 'b    | ]setLocalVars a 'a = ; shouldBeTrue
:: 0 -> a 1 -> b [ 'a 'b    | ]setLocalVars b 'b = ; shouldBeTrue
:: 0 -> a 1 -> b [          | ]setLocalVars a  0 = ; shouldBeTrue
:: 0 -> a 1 -> b [          | ]setLocalVars b  1 = ; shouldBeTrue


( Tests 125-134: )

: aa {[ 'a ; 'b 0 'c 1 ; :d nil :e t ]} [ a | ; 
: bb {[ 'a ; 'b 0 'c 1 ; :d nil :e t ]} [ b | ; 
: cc {[ 'a ; 'b 0 'c 1 ; :d nil :e t ]} [ c | ; 
: dd {[ 'a ; 'b 0 'c 1 ; :d nil :e t ]} [ d | ; 
: ee {[ 'a ; 'b 0 'c 1 ; :d nil :e t ]} [ e | ; 

:: [ 13                   | aa ]shift 13       =   ; shouldBeTrue
:: [ 13                   | bb ]shift 0        =   ; shouldBeTrue
:: [ 13                   | cc ]shift 1        =   ; shouldBeTrue
:: [ 13                   | dd ]shift lisp:nil =   ; shouldBeTrue
:: [ 13                   | ee ]shift lisp:t   =   ; shouldBeTrue

:: [ 13 14 15 :e 17 :d 16 | aa ]shift 13       =   ; shouldBeTrue
:: [ 13 14 15 :e 17 :d 16 | bb ]shift 14       =   ; shouldBeTrue
:: [ 13 14 15 :e 17 :d 16 | cc ]shift 15       =   ; shouldBeTrue
:: [ 13 14 15 :e 17 :d 16 | dd ]shift 16       =   ; shouldBeTrue
:: [ 13 14 15 :e 17 :d 16 | ee ]shift 17       =   ; shouldBeTrue


